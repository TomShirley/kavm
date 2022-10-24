param ($FluxRepoUrl, $PrivateKeyFile, $PrivateKeyFilePassword)

flux create source git kavm `
    --url=$FluxRepoUrl `
    --private-key-file=$PrivateKeyFile `
    --password=$PrivateKeyFilePassword `
    --branch=main `
    --interval=30s `
    --ssh-key-algorithm=ecdsa `
    --ssh-ecdsa-curve=p521
