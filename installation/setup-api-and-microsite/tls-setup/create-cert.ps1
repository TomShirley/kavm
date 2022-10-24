echo "Creating self-signed CA certificates for TLS and installing them in the local trust stores"
$CA_CERTS_FOLDER="$(pwd)\.certs"
# This requires mkcert to be installed/available
echo ${CA_CERTS_FOLDER}
rm -r -force ${CA_CERTS_FOLDER}
mkdir -p ${CA_CERTS_FOLDER}
mkdir -p ${CA_CERTS_FOLDER}/${ENVIRONMENT}
# The CAROOT env variable is used by mkcert to determine where to read/write files
# Reference: https://github.com/FiloSottile/mkcert
# The following powershell one-liner sets the CAROOT to the current directory, set the TRUST_STORES to system only, and creates and installs the CA certs in the system store.
$env:CAROOT = "${CA_CERTS_FOLDER}\${ENVIRONMENT}"; $env:TRUST_STORES = 'system'; mkcert -install

