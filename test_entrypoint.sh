#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

write_fake_ffmpeg() {
  local fakebin="$1"
  local exit_code="$2"
  local output_text="$3"

  cat > "${fakebin}/ffmpeg" <<FAKE_FFMPEG
#!/usr/bin/env sh
format=""
out=""
previous=""
for arg in "\$@"; do
  if [ "\$previous" = "-f" ]; then
    format="\$arg"
  fi
  if [ "\$arg" != "-y" ] && [ "\$previous" != "-i" ] && [ "\$previous" != "-c" ] && [ "\$previous" != "-f" ] && [ "\$arg" != "-i" ] && [ "\$arg" != "-c" ] && [ "\$arg" != "copy" ] && [ "\$arg" != "-f" ]; then
    out="\$arg"
  fi
  previous="\$arg"
done

case "\$out" in
  *.mp4|*.m4v) ;;
  *)
    if [ "\$format" != "mp4" ]; then
      echo "Unable to choose an output format for '\$out'" >&2
      exit 1
    fi
    ;;
esac

printf '${output_text}' > "\$out"
exit ${exit_code}
FAKE_FFMPEG
  chmod +x "${fakebin}/ffmpeg"
}

test_failed_conversion_marks_ts_failed_and_removes_partial_mp4() {
  local tmpdir fakebin workdir
  tmpdir="$(mktemp -d)"
  fakebin="${tmpdir}/bin"
  workdir="${tmpdir}/downloads"
  mkdir -p "${fakebin}" "${workdir}"
  write_fake_ffmpeg "${fakebin}" 137 "partial output"

  printf 'video data' > "${workdir}/broken.ts"

  PATH="${fakebin}:${PATH}" WORKDIR="${workdir}" SLEEPTIME=0 RUN_ONCE=true "${repo_root}/entrypoint.sh" >/tmp/ffmpeg-test.log 2>&1

  test -f "${workdir}/broken.ts.failed"
  test ! -f "${workdir}/broken.ts"
  test ! -f "${workdir}/broken.mp4.part"

  rm -rf "${tmpdir}"
}

test_failed_conversion_preserves_existing_mp4() {
  local tmpdir fakebin workdir
  tmpdir="$(mktemp -d)"
  fakebin="${tmpdir}/bin"
  workdir="${tmpdir}/downloads"
  mkdir -p "${fakebin}" "${workdir}"
  write_fake_ffmpeg "${fakebin}" 137 "partial output"

  printf 'video data' > "${workdir}/existing.ts"
  printf 'previous good output' > "${workdir}/existing.mp4"

  PATH="${fakebin}:${PATH}" WORKDIR="${workdir}" SLEEPTIME=0 RUN_ONCE=true "${repo_root}/entrypoint.sh" >/tmp/ffmpeg-test.log 2>&1

  test -f "${workdir}/existing.ts.failed"
  test -f "${workdir}/existing.mp4"
  grep -q 'previous good output' "${workdir}/existing.mp4"
  test ! -f "${workdir}/existing.mp4.part"

  rm -rf "${tmpdir}"
}

test_successful_conversion_moves_part_to_mp4_and_removes_ts() {
  local tmpdir fakebin workdir
  tmpdir="$(mktemp -d)"
  fakebin="${tmpdir}/bin"
  workdir="${tmpdir}/downloads"
  mkdir -p "${fakebin}" "${workdir}"
  write_fake_ffmpeg "${fakebin}" 0 "complete output"

  printf 'video data' > "${workdir}/good.ts"

  PATH="${fakebin}:${PATH}" WORKDIR="${workdir}" SLEEPTIME=0 RUN_ONCE=true "${repo_root}/entrypoint.sh" >/tmp/ffmpeg-test.log 2>&1

  test -f "${workdir}/good.mp4"
  grep -q 'complete output' "${workdir}/good.mp4"
  test ! -f "${workdir}/good.mp4.part"
  test ! -f "${workdir}/good.ts"
  test ! -f "${workdir}/good.ts.failed"

  rm -rf "${tmpdir}"
}

test_failed_conversion_marks_ts_failed_and_removes_partial_mp4
test_failed_conversion_preserves_existing_mp4
test_successful_conversion_moves_part_to_mp4_and_removes_ts

echo "entrypoint tests passed"
