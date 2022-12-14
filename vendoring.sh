#! /bin/env bash

die() {
  echo "[ERROR] $*"
  exit 1
}

info() {
  echo "[INFO] $*"
}

PN="${1}"
PV="${2}"
SRC_URI="${3}"
P="${PN}-${PV}"
S="${4:-${P}}"

tmpdir="$(mktemp -d)"
archivedir="${PWD}/dep-archives"
export GOMODCACHE="${PWD}/go-mod"

mkdir -p "${archivedir}" || die "Failed to create ${archivedir}"
cd "${tmpdir}" || die "cd ${tmpdir} failed"

info "Building modcache for ${P} from source ${SRC_URI}"

info "Fetching source"
eval "wget --no-verbose ${SRC_URI}" || die "wget failed"
eval "file=\$(basename \"${SRC_URI}\")"

info "Extracting source"
tar -xf "${file}" || die

pushd "${S}" || die "pushd ${S} failed"
info "Generating vendor file"
go mod vendor
popd

info "Packing vendor"
tar --create --auto-compress --file ${P}-deps.tar.xz ${S}/vendor || die

mv ${P}-deps.tar.xz "${archivedir}" || die "Failed to move ${P}-deps.tar.xz to archivedir"
