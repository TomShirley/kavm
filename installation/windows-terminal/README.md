# Install Windows Terminal

1. First up, install Powershell Core (which replaces powershell classic): https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1 
2. Follow the windows terminal install guide here: https://docs.microsoft.com/en-us/windows/terminal/get-started 

# Make the dev experience better!

Run through the below steps for both Powershell and WSL shells

## For Powershell

1. Scott H's guide will get you mostly there: https://www.hanselman.com/blog/how-to-make-a-pretty-prompt-in-windows-terminal-with-powerline-nerd-fonts-cascadia-code-wsl-and-ohmyposh

> :grey_exclamation: Make sure you run these steps in powershell core within windows terminal (not powershell classic which is the default shell in windows terminal. Click the down arrow in the top toolbar in windows terminal and select 'powershell' for powershell core.


2. Check that your execution policy is lax so that scripts will run when you start a shell:
> ```powershell 
> Set-ExecutionPolicy -ExecutionPolicy Unrestricted
> ```

3. Configure your prompt/theme
    - List available themes
    ```powershell
    Get-PoshThemes
    ```
    - Set a theme
    ```powershell
    Set-PoshPrompt -Theme <theme-name>
    ```
    - Update your powershell profile so that the theme sticks next time you open a shell
    ```powershell
    code $profile #to open your powershell profile and copy/paste the command you used to set the posh prompt theme.
    ```
> :grey_question: If you see weird square blocks in your terminal, make sure to download the CaskaydiaCove font from https://www.nerdfonts.com/, and then within settings in windows terminal, click on the powershell profile on the left menu and go to Appearance and select CaskaydiaCove NF

> :point_right: to add the same icon support in VS Code's in-built terminal, set the follow setting in VSCode:
>   ```Terminal › Integrated: Font Family = CaskaydiaCove NF```

4. Add some more icon support, follow: https://www.hanselman.com/blog/take-your-windows-terminal-and-powershell-to-the-next-level-with-terminal-icons 

5. Enable predictive intellisense
    * In your profile, add: ```Set-PSReadLineOption -PredictionSource History```


## For WSL 

The below steps to setup WSL are here so that you can run the validate.sh bash script. So, not absolutely necessary, but here for completness if you want to customize the WSL linux shell along side windows terminal :) 

1. Once WSL is installed and you have an ubuntu terminal open inside of windows terminal, you'll need to install pip: ```sudo apt install python3-pip```
2. Setup VSCode so that you can use VSCode on top of WSL: https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers#install-docker-desktop

> :warning: Create your repos directory under the home location (>cd ~) of ubuntu/linux for performance reasons See: https://docs.microsoft.com/en-us/windows/wsl/compare-versions#performance-across-os-file-systems

3. Install Zsh
    - ```sudo apt install zsh```
    - Logout and log back in to test zsh shell
    -  In the shell it will ask to create a zsh config file, just hit q for now
4. Install oh-my-zsh: ```sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"```
5. Setup zsh plugins
    - Install antigen plugin manager in a folder of your choice: ```curl -L git.io/antigen > antigen.zsh```
    - Follow this guide here: https://blog.phuctm97.com/zsh-antigen-oh-my-zsh-a-beautiful-powerful-robust-shell
        - We now need to edit the zsh config file, which is found at the home dir: ```cd ~```
	        - List out all contents of this dir: ```ls -a```
      	    - To edit this file you could use vim, but I prefer to use VSCode. Simply: ```code .```	
            - In VSCode, edit the file .zshrc. I've set the location where the antigen script file is:
			
            ```
            # Load Antigen
			source "/home/<your-user-name>/antigen.zsh"
			```
		- Then in my .antigenrc file, it ends up looking like this:
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
6. Install Powerline
    - install go and then powerline 
    ```		
    sudo apt install golang-go
    go get -u github.com/justjanne/powerline-go
    ```
    - Add this to your ~/.bashrc. You may already have a GOPATH so be aware.
    ```
    GOPATH=$HOME/go
    function _update_ps1() {
    PS1="$($GOPATH/bin/powerline-go -error $?)"
    }
    if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi
    ```
    - Make sure you've installed the caskaydiacove font already. If not, go to https://www.nerdfonts.com/ and right click the downloaded font file and install for all users
    - Set your font in windows terminal's settings.json file so that it will use the cool font for your ubuntu terminal:
    ```json
    "fontFace": "CaskaydiaCove NF"
    ```
7. Install a good zsh theme
    - Get Powerlevel10k: https://github.com/romkatv/powerlevel10k
        - To install this via antigen, just add this line to your .antigenrc file:
        ```				
        # Select theme
        antigen theme romkatv/powerlevel10k
        ```
    - You will be prompted to configure powerlevel10k when you now open your ubuntu terminal.

> If your VSCode's WSL terminal shows square blocks instead of the installed font, go to settings and update the font to CaskaydiaCove NF
 