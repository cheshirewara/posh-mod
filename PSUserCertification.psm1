# モジュール内共通定数
#######################################################################
$ERRACTION = "Stop"          # エラーアクション
#######################################################################
<#
.Synopsis
   資格情報を生成する。
.DESCRIPTION
   平文PASSとユーザ名から資格情報を生成する。
.INPUTS
   System.String
.EXAMPLE
   Another example of how to use this cmdlet
#>
Function New-Credential
 {
    [CmdletBinding()]
    [Alias()]
    [OutputType([System.Management.Automation.PSCredential])]

    param
    (
        # ユーザ名を指定する。
        [Parameter(Mandatory = $True , Position = 0)]
        [System.String]
        $UserName,

        # パスワードを指定する。（平文）
        [Parameter(Mandatory = $True , Position = 1)]
        [System.String]
        $Password
    )
    
    begin
    {}
    Process
    {
        ####################
        #関数内のエラー処理
        ####################
        $ErrorActionPreference = $ERRACTION
        trap { break }

        ####################
        #関数メイン処理
        ####################
        ## 平文パスワードを型変換
        $SeqPassword = ConvertTo-SecureString $Password -asplaintext -force
        # コンストラクタを使用して資格情報を生成
        $cred = New-Object System.Management.Automation.PsCredential($UserName,$SeqPassword)

        # 新資格情報を返す
        return $cred
    }
    End
    {}
}    
#######################################################################
<#
.Synopsis
   ネットワークドライブに接続する。
.DESCRIPTION
   ネットワークドライブに接続する。接続前に指定したドライブ名に空きがあるか確認し、存在した場合は
   一旦削除してから接続する。
   ※認証なしでも可能な場合もユーザパスを指定する（要改善）
.INPUTS
   System.String[]
.EXAMPLE
   
#>
Function Connect-NetDrive
 {
    [CmdletBinding()]
    [Alias()]
    [OutputType([System.Management.Automation.PSDriveInfo])]

    param
    (
        # 接続時に作成するドライブ名を指定する。
        [Parameter(Mandatory = $True , Position = 0)]
        [System.String]
        $DriveName,

        # 接続先のルートフォルダ名を指定する。
        [Parameter(Mandatory = $True , Position = 1)]
        [System.String]
        $DriveRoot,

        # ユーザ名を指定する。
        [Parameter(Mandatory = $True , Position = 2)]
        [System.String]
        $UserName,

        # パスワードを指定する。（平文）
        [Parameter(Mandatory = $True , Position = 3)]
        [System.String]
        $Password
    )
    
    begin
    {}
    Process
    {
        ####################
        #関数内のエラー処理
        ####################
        $ErrorActionPreference = $ERRACTION
        trap { break }

        ####################
        #関数メイン処理
        ####################
        # 資格情報作成
        $cred = New-Credential -UserName $UserName -Password $Password

        # ドライブのゴミ情報を掃除
        if ((Get-PSDrive).Name.Contains($DriveName))
        {
            Remove-PSDrive -Name $DriveName -Force
        }

        # ネットワークドライブ接続
        $driveInfo = New-PSDrive -Name $DriveName -PSProvider FileSystem `
            -Root $DriveRoot -Credential $cred -Scope 2 -Persist

        # 戻り値
        return $driveInfo
    }
    End
    {}
}    
