$todofile = "$PSScriptRoot\TODO.md"

$excludeFolders = @('bin', 'obj', 'packages')

$excludePattern = [string]::Join('|', ($excludeFolders | % {'\\' + $_ + '\\?' }))
$todoMark = '// ' + 'TODO'

$pwd = (pwd).Path + '\'

$todos = gci $PSScriptRoot -r `
        | ? { $_.FullName -ne $todofile } `
        | ? { $_.FullName -notmatch $excludePattern } `
        | select-string $todoMark `
        | % { new-object PSObject `
                -Prop @{ Path = $_.Path.Replace($PSScriptRoot, ''); `
                         LineNum = $_.LineNumber; `
                         Task = $_.Line.SubString($_.Line.IndexOf($todoMark) + $todoMark.Length + 1).Trim() `
                       } }

$todoContents = cat $todofile

$srcTodoDelim = 'Source TODOs'

$srcTodoLineNum = $todoContents.IndexOf($srcTodoDelim) + 1

$cleanTodoLines = $todoContents[0..$srcTodoLineNum] + ""

$file = $null
foreach ($todo in $todos)
{
    if ($file -ne $todo.Path)
    {
        $file = $todo.Path
        $cleanTodoLines += "* $($todo.Path)"
    }
    $cleanTodoLines += "    * $($todo.LineNum) $($todo.Task)"
}

$encoding = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllLines($todoFile, $cleanTodoLines, $encoding)