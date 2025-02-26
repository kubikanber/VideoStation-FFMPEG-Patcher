#!/bin/bash

###############################
# VARS
###############################

ffmpeg_version=ffmpeg
# shellcheck source=/.github/workflows/mock/VERSION
source "/etc/VERSION"
# shellcheck source=/patch_config.sh
source "/var/packages/VideoStation/patch_config.sh" || echo "No patch_config.sh"
dsm_version="$productversion $buildnumber-$smallfixnumber"
vs_path=/var/packages/VideoStation
cp_path=/var/packages/CodecPack

###############################
# UTILS
###############################

function root_check() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "This tool needs root access (please run 'sudo -i' before proceeding)."
    exit 1
  fi
}

################################
# ENTRYPOINT
################################

root_check

echo "
================ ISSUE REPORT TOOL ================
https://github.com/AlexPresso/VideoStation-FFMPEG-Patcher

System Details.....................................
  DSM Version: $dsm_version
  Arch details: $(uname -a)

Package Details....................................
  VideoStation version: $(synopkg version VideoStation || echo "Not installed")
  FFMPEG version ($ffmpeg_version): $(synopkg version "${ffmpeg_version}" || echo "Not installed")
  CodecPack version: $(synopkg version CodecPack || echo "Not installed")

Patch Details......................................
  Is patched ? $([ -f "$vs_path/target/lib/libsynovte.so.orig" ] && echo "yes" || echo "no")
  Has gstreamer ? $([ -f "$vs_path/target/bin/gst-launch-1.0" ] && echo "yes" || echo "no")

FFMPEG VAAPI.......................................
  $("/var/packages/${ffmpeg_version}/target/bin/vainfo" || echo "No VAAPI Support")

CodecPack Details..................................
  Has AAC ? $([ -f "$cp_path/target/pack/HAS_AAC" ] && echo "yes" || echo "no")
  Has HEVC ? $([ -f "$cp_path/target/pack/HAS_HEVC" ] && echo "yes" || echo "no")
"

echo "CodecPack target/bin content......................."
ls -l "$cp_path/target/bin"
echo ""
echo "CodecPack target/pack/bin content.................."
ls -l "$cp_path/target/pack/bin"
echo ""
echo "CodecPack status..................................."
cat "$cp_path/var/codec_requirements.json" || echo "file not exists"

echo ""

echo ""
echo "GSTInspect last stderr logs........................"
tail -22 /tmp/gstinspect*.stderr
echo ""
echo "GSTInspect stderr.prev logs........................"
cat /tmp/gstinspect*.stderr.prev
echo ""
echo "GSTLaunch last stderr logs........................."
tail -22 /tmp/gstlaunch*.stderr
echo ""
echo "GSTLaunch stderr.prev logs........................."
cat /tmp/gstlaunch*.stderr.prev

echo ""
echo "FFMPEG head logs..................................."
head /tmp/ffmpeg*.stderr
echo ""
echo "FFMPEG last stderr logs............................"
tail -22 /tmp/ffmpeg*.stderr

echo ""
echo "FFMPEG prev logs..................................."
cat /tmp/ffmpeg*.stderr.prev
echo ""
