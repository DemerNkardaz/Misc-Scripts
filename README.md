# Misc-Scripts

Just some scripts for me.

All scripts created with AI.

## PowerShell Lists Scripts

This scripts I use to generate files and folder lists.

I run it via context menu with command like «powershell.exe -ExecutionPolicy RemoteSigned -File "(HERE SCRIPT PATH & NAME).ps1" "%V"»

[CurrentFiles.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/CurrentFiles.ps1) & [CurrentFiles_Clip.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/CurrentFiles_Clip.ps1) gets current directory file names, first script creates _files.txt, second just copy list to clipboard (with creating and removing temporary _files.txt).

[CurrentFiles_WithoutFormat.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/CurrentFiles_WithoutFormat.ps1) & [CurrentFiles_WithoutFormat_Clip.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/CurrentFiles_WithoutFormat_Clip.ps1) works identically of above, but creating list without file extensions in names.

[CurrentFolders.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/CurrentFolders.ps1) & [CurrentFolders_Clip.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/CurrentFolders_Clip.ps1) similar of above for current directory folder names, output file is _folders.txt.

[GenerateHTML_Lists.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/GenerateHTML_Lists.ps1) & [GenerateHTML_Lists_Clip.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/GenerateHTML_Lists_Clip.ps1) is for generate a deep HTML list with spans of current directory with structure like this without file extension in names:

Output file _list.html.

[GenerateHTML_Lists_OutFileDirName.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/GenerateHTML_Lists_OutFileDirName.ps1) creates .html file with current directory name.

```html
<li><span>ingame</span>
    <ul>
    <li><span>eldar_icons</span>
        <ul>
            <li><span>avatar_icon</span></li>
        </ul>
    </li>
    <li><span>event_cue_icons</span>
        <ul>
        <li><span>custom</span>
            <ul>
                <li><span>player_donation</span></li>
            </ul>
        </li>
        </ul>
    </li>
        <li><span>generic_icon</span></li>
    </ul>
</li>
```

[GenerateJSON_Lists.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/GenerateJSON_Lists.ps1) & [GenerateJSON_Lists_Clip.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/GenerateJSON_Lists_Clip.ps1) is for generate a deep JSON table similar of above with structure like this («link» is used for my some JS needs):

Output file _table.json.

[GenerateJSON_Lists_OutFileDirName.ps1](https://github.com/DemerNkardaz/Misc-Scripts/blob/main/PowerShell/GenerateJSON_Lists_OutFileDirName.ps1) creates .json file with current directory name.

```json
{
    "root": [
        {
            "name": "ingame",
            "link": "",
            "childs": [
                {
                    "name": "eldar_icons",
                    "link": "",
                    "childs": [
                        {
                            "name": "avatar_icon",
                            "link": ""
                        }
                    ]
                },
                {
                    "name": "event_cue_icons",
                    "link": "",
                    "childs": [
                        {
                            "name": "custom",
                            "link": "",
                            "childs": [
                                {
                                    "name": "player_donation",
                                    "link": ""
                                }
                            ]
                        }
                    ]
                },
                {
                    "name": "generic_icon",
                    "link": ""
                }
            ]
        }
    ]
}
```
