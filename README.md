# Forever

Very simple `PowerShell` module for waiting forever.

Build using

```
$ dotnet publish Forever.csproj --configuration Release
```

Install by copying the publish into a directory on the [PSModulePath](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)

## Stoppable test

Run the `test.ps1` to confirm it works. The task should be stopped after five seconds.

## Unstoppable test

Run with the stoppable flag set to false

```
PS>./test.ps1 -Stoppable $False
```

This should stop after sixty seconds when the count limit is reached.
