#!/usr/bin/env pwsh
#
#  Copyright 2023, Roger Brown
#
#  This file is part of rhubarb-geek-nz/Forever.
#
#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
# 
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>
#

param(
	$LogFile = "$PSScriptRoot/forever.log",
	$Stoppable = $true,
	$Timeout = 1000,
	$Count = 60
)

Write-Host $LogFile $Stoppable $Timeout $Count

Add-Content -Path $LogFile -Value "start"

$ErrorActionPreference = "Stop"

trap
{
	throw $PSItem
}

$job = Start-ThreadJob -ScriptBlock {
	param($LogFile,$Stoppable,$Timeout,$Count)
	try
	{
		try
		{
			Wait-Forever $LogFile $Stoppable $Timeout $Count
		}
		finally
		{
			Add-Content -Path $LogFile -Value "finally"
		}
	}
	catch
	{
		Add-Content -Path $LogFile -Value "catch $PSItem"
	}
} -ArgumentList $LogFile,$Stoppable,$Timeout,$Count

Start-Sleep -Seconds 5

$job | Remove-Job -Force

Start-Sleep -Seconds 5

Get-Content -Path $LogFile
