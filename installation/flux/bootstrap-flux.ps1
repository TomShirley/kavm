param ($Environment)

flux create kustomization flux-system `
    --source=kavm `
    --path="./clusters/$Environment" `
    --prune=true `
    --interval=5m

flux export source git kavm > ../../clusters/$Environment/flux-system/gotk-sync.yaml
flux export kustomization flux-system >> ../../clusters/$Environment/flux-system/gotk-sync.yaml

cd ../../clusters/$Environment/flux-system && kustomize create --autodetect
