# Install Windows Terminal

1. First up, install Powershell Core (which replaces powershell classic): https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1 
2. Follow the windows terminal install guide here: https://docs.microsoft.com/en-us/windows/terminal/get-started 

# Make the dev experience better!

Run through the below steps for both Powershell and WSL shells

## For Powershell

> :grey_exclamation: Make sure you run these steps in powershell core within windows terminal (not powershell classic which is the default shell in windows terminal. Click the down arrow in the top toolbar in windows terminal and select 'powershell' for powershell core.

1. With PowerShell, you must ensure Get-ExecutionPolicy is not Restricted. Suggest using Bypass to bypass the policy to get things installed or AllSigned for quite a bit more security.

   - Run `Get-ExecutionPolicy`. If it returns `Restricted`, then run `Set-ExecutionPolicy AllSigned` or `Set-ExecutionPolicy Bypass -Scope Process`.

2. Add posh-git and oh-my-posh
   - Install posh-git: `Install-Module posh-git -Scope CurrentUser` Guide here if you run into issues: https://github.com/dahlbyk/posh-git#installation
   - Install oh-my posh: `winget install JanDeDobbeleer.OhMyPosh -s winget`, guide here if you run into issues: https://ohmyposh.dev/docs/installation/windows
   - Close your terminal and open a new one as admin

3. Configure oh-my-posh to change your prompt
   1. Open your profile so that you can edit it: `notepad $PROFILE`
   2. add `oh-my-posh init pwsh | Invoke-Expression`

> :information_source: you can also configure a theme as a param to the oh-my-posh app on profile startup, see https://ohmyposh.dev/docs/installation/customize

4. Add fonts used for the prompt
> :grey_question: If you see weird square blocks in your terminal this step fixes it
   - Run `oh-my-posh font install` and pick CaskaydiaCove (as an example)
   - Configure windows terminal to use the installed font for your shell:
     -  Open the settings page in Windows Terminal
     -  Click on your powershell shell in the left menu (under 'Profiles') on the, and go to Appearance.
     -  In the 'Font Face' config section, select 'CaskaydiaCove NF Mono'

> :grey_question: If that doesn't work, try and download the font directly at https://www.nerdfonts.com/font-downloads. Unzip the CaskaydiaCove zip file on your pc and right click, select "Install for all users". Back in windows terminal: click on your powershell profile in the left menu (under 'Profiles') and go to Appearance -> In the 'Font Face' config section, select 'CaskaydiaCove NF Mono'

5. Set a theme for your prompt. To list available themes `Get-PoshThemes`
   - When you find one that you like, apply it when oh-my-posh starts by updating your $profile:
     - e.g. `oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/atomicBit.omp.json" | Invoke-Expression`

> :point_right: to add the same icon support in VS Code's in-built terminal, set the follow setting in VSCode:
>   ```Terminal › Integrated: Font Family = CaskaydiaCove NF```

6. Add some more icon support, follow: https://www.hanselman.com/blog/take-your-windows-terminal-and-powershell-to-the-next-level-with-terminal-icons 

7. Enable predictive intellisense by adding this line in your profile: ```Set-PSReadLineOption -PredictionSource History```


## For WSL 

The below steps to setup WSL are here so that you can run the validate.sh bash script. So, not absolutely necessary, but here for completness if you want to customize the WSL linux shell along side windows terminal.

### pre-reqs

1. WSL installed. see https://learn.microsoft.com/en-us/windows/wsl/install
2. Ubuntu for WSL installed
   - To install it, open the microsoft store on your pc, search for 'ubuntu' and install the distro.

### WSL customization

1. Once WSL is installed and you have an ubuntu terminal open inside of windows terminal, you'll need to install pip: ```sudo apt-get update | sudo apt install python3-pip```
2. Setup VSCode so that you can use VSCode on top of WSL: https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers#install-docker-desktop

> :raising_hand: Down the line, if you are working with git repositories in a wsl shell, ensure your git directory is under the home location (>cd ~) of ubuntu/linux for performance reasons See: https://docs.microsoft.com/en-us/windows/wsl/compare-versions#performance-across-os-file-systems

3. Install Zsh
    - ```sudo apt install zsh```
    - Logout and log back in to test zsh shell
    -  In the shell it will ask to create a zsh config file, just hit q for now
4. Install oh-my-zsh: ```sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"```
5. Setup zsh plugins
    - Install antigen plugin manager in a folder of your choice: ```curl -L git.io/antigen > antigen.zsh```
        > below steps adapter from : https://blog.phuctm97.com/zsh-antigen-oh-my-zsh-a-beautiful-powerful-robust-shell
        - We now need to edit the zsh config file, which is found at the home dir: ```cd ~```
	        - List out all contents of this dir: ```ls -a```
      	    - To edit this file you could use vim, but I prefer to use VSCode. Simply: ```code .```	
            - In VSCode, edit the file .zshrc. Set the location where the antigen script file is:
			
            ```
            # Load Antigen
			source "/home/<your-user-name>/antigen.zsh"
			```
		- Then in the same .zshrc file, add the following config:
        ```text
            # Load oh-my-zsh library
            antigen use oh-my-zsh
            
            # Load bundles from the default repo (oh-my-zsh)
            antigen bundle git
            antigen bundle command-not-found
            antigen bundle docker
            
            # Load bundles from external repos
            antigen bundle zsh-users/zsh-completions
            antigen bundle zsh-users/zsh-autosuggestions
            antigen bundle zsh-users/zsh-syntax-highlighting
            
            # Turn on an Oh my Zsh plugin
            antigen bundle git
            antigen bundle command-not-found
            antigen bundle docker
            
            # Tell Antigen that you're done
            antigen apply
        ```
        - close your shell and open a new one
6. Install a good zsh theme
    - Get Powerlevel10k: https://github.com/romkatv/powerlevel10k
        - To install this via antigen, just add this line to your .zshrc file:
        ```				
        # Select theme
        antigen theme romkatv/powerlevel10k
        ```
    - You will be prompted to configure powerlevel10k when you now open your ubuntu terminal. It will also install fonts for you.

> If your VSCode's WSL terminal shows square blocks instead of the installed font, go to settings and update the font to CaskaydiaCove NF

