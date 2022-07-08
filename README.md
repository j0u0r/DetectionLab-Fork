# Annotated Detectionlab
> Version last updated 24 June 2022
- Main file: ***/Vagrant/Vagrantfile*** (coded in ruby)
- Important scripts (***/Vagrant/scripts***):
  > - ***fix-second-network.ps1*** (configures second network for domain)
  > - ***provision.ps1*** (main file for configuring vm)
  > - ***fix-windows-expiration.ps1*** (renews Windows expiration date)
  > - ***create-domain.ps1*** (creates domain)
  > - ***join-domain.ps1*** (joins domain)
  > - ***configure-ou.ps1*** (creates Organizational Units)
  > - ***All GPO scripts*** (creates GPO; but not relevant to the FYP project)
  
- Useful scripts (***/Vagrant/scripts***):
  > - ***install-bginfo.ps1*** (customises desktop that provides useful info like IP and domain)
  > - ***install-utilities.ps1*** (useful utilities like Google Chrome, Chocolatey)
  > - ***install-redteam.ps1*** (install red team tools; uses Invoke-CommandAs.ps1 but not sure what purpose)
  > - ***install-choco-extras.ps1*** (installs Wireshark, Winpcap; requires Chocolatey)
  > - ***install-sysinternals.ps1*** (installs ProcMon, Autoruns, Process Explorer, etc.)
  > - ***configure-taskbar-layout-gpo.ps1*** (creates GPO to customise taskbar layout)
  > - ***MakeWindows10GreatAgain.ps1*** (disables auto screen turnoff, cortana, remove Onedrive, and other useful stuff)
  
- Important resources:
  > - ***/Vagrant/resources/GPO*** (folder containing all GPO object exports to be used to create GPOs)
  
- Useful resources:
  > - ***/Vagrant/resources/windows/background.bmp*** (wallpaper image)
  > - ***/Vagrant/scripts/bginfo.bgi*** (bginfo configuration file)
  
# Adapt Imitate cloner (WIP)
> - Adapt Imitate is part of ADAPT(Active Directory Automation PlaTform), a Final Year Project that me and my group is working on. This project focuses on automated processes, so everything will be automated and won't be so troublesome for users.
> - ADAPT has 2 parts, Imitate and Assault. Imitate is to enumerate an AD environment, then make a new virtual AD environment using the obtained information, sort of like replication. Assault then pentests the 'cloned' AD environment.
> - For this project, i have been tasked to create the 'cloning' part of Adapt Imitate. You can find everything i've done in the links below!  
- I have annotated Detectionlab, which is built using Vagrant, to learn and familiarise myself with Vagrant.
  - Link to forked repository: https://github.com/j0u0r/DetectionLab-Fork
- I have created an AD environment using Vagrant that will be used as the victim. Instructions, more information and troubleshooting is provided in the repository.
  - Link to repository: https://github.com/j0u0r/vagrant-victim  
- I have created a program that clones an AD environment using information provided in a csv file. Instructions, more information and troubleshooting is provided in the repository.  
  - Link to repository: https://github.com/j0u0r/ADAPT-Imitate-Cloner
  
****THIS IS NOT THE WHOLE PROJECT! ONLY MY PART :(***
## Resources used
- Vagrant v2.2.19
  > - Website: https://www.vagrantup.com/
  > - Downloads:
  >    - https://www.vagrantup.com/downloads (main; recommended download)
  >    - https://www.vagrantup.com/vmware/downloads (vmware utility v1.0.21)
  > - Github: https://github.com/hashicorp/vagrant.git
- Ruby v3.1.2 (to develop Vagrant; not so sure whether it's needed but i installed it anyway)
  >  - Website: https://www.ruby-lang.org/en/
  >  - Download: https://www.ruby-lang.org/en/downloads/
- Detectionlab (last updated 24 June 2022)
  >  - Website: https://detectionlab.network/
  >  - Download/Github: https://github.com/clong/DetectionLab
- Python v3.10.4
  > - Website: https://www.python.org/
  > - Download: https://www.python.org/downloads/
