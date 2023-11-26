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
	$ProjectName = 'Forever',
	$PublishDir = 'bin/Release/netstandard2.0/publish/'
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$compatiblePSEdition = 'Core'
$PowerShellVersion = '7.2'

trap
{
	throw $PSItem
}

function Get-SingleNodeValue([System.Xml.XmlDocument]$doc,[string]$path)
{
    return $doc.SelectSingleNode($path).FirstChild.Value
}

$xmlDoc = [System.Xml.XmlDocument](Get-Content "$ProjectName.csproj")

$ModuleId = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/PackageId'
$Version = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Version'
$ProjectUri = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/PackageProjectUrl'
$Description = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Description'
$Author = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Authors'
$Copyright = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Copyright'
$AssemblyName = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/AssemblyName'
$CompanyName = Get-SingleNodeValue $xmlDoc '/Project/PropertyGroup/Company'

@"
@{
	RootModule = '$AssemblyName.dll'
	ModuleVersion = '$Version'
	GUID = '4f12c796-8ae5-405b-a423-18dbf6258539'
	Author = '$Author'
	CompanyName = '$CompanyName'
	Copyright = '$Copyright'
	PowerShellVersion = "$PowerShellVersion"
	CompatiblePSEditions = @('$compatiblePSEdition')
	Description = '$Description'
	FunctionsToExport = @()
	CmdletsToExport = @('Wait-$ProjectName')
	VariablesToExport = '*'
	AliasesToExport = @()
	PrivateData = @{
		PSData = @{
			ProjectUri = '$ProjectUri'
		}
	}
}
"@ | Set-Content -Path "$PublishDir$ModuleId.psd1"

(Get-Content "./README.md")[0..2] | Set-Content -Path "$PublishDir/README.md"
