param ($env, $environment='local')

kubectl apply -f ./flux-system-namespace.yaml

flux install --version=v0.33.0 `
	--namespace=flux-system `
	--components=source-controller,kustomize-controller,helm-controller,notification-controller `
	--components-extra=image-reflector-controller,image-automation-controller

#the comand is run the second time to export to kubernetes resources. When combined as per the documentation it does not execute successfully.
flux install --version=v0.33.0 `
	--namespace=flux-system `
	--components=source-controller,kustomize-controller,helm-controller,notification-controller `
	--components-extra=image-reflector-controller,image-automation-controller `
	--export > ../../clusters/$environment/flux-system/gotk-components.yaml
