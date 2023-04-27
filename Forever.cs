/**************************************************************************
 *
 *  Copyright 2023, Roger Brown
 *
 *  This file is part of rhubarb-geek-nz/Forever.
 *
 *  This program is free software: you can redistribute it and/or modify it
 *  under the terms of the GNU Lesser General Public License as published by the
 *  Free Software Foundation, either version 3 of the License, or (at your
 *  option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

using System;
using System.IO;
using System.Management.Automation;
using System.Threading;

namespace Forever
{
    [Cmdlet("Wait", "Forever")]
    public class WaitForever : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string LogFile { get; set; }
        [Parameter(Mandatory = false, Position = 1)]
        public bool Stoppable { get; set; }
        [Parameter(Mandatory = false, Position = 2)]
        public int Timeout { get; set; } = 1000;
        [Parameter(Mandatory = false, Position = 3)]
        public int Count { get; set; } = 60;

        CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();

        protected override void BeginProcessing() => WriteLog("Forever-BeginProcessing");

        protected override void ProcessRecord()
        {
    	    int i = 0;

			try
			{
	            var cancellationToken = cancellationTokenSource.Token;

	            WriteLog("Forever-ProcessRecord-Begin");

	            while (i < Count && !cancellationToken.IsCancellationRequested)
    	        {
        	        WriteLog($"Forever-ProcessRecord-Wait {i}");

	                if (cancellationToken.WaitHandle.WaitOne(Timeout))
    	            {
        	            WriteLog("Forever-ProcessRecord-Break");

	                    break;
    	            }
	
    	            i++;
        	    }
			}
			finally
			{
				using (var disposable = cancellationTokenSource)
				{
					cancellationTokenSource = null;
				}

	            WriteLog($"Forever-ProcessRecord-End {i}");
			}
        }

        protected override void EndProcessing() => WriteLog("Forever-EndProcessing");

        protected override void StopProcessing()
        {
            if (Stoppable && cancellationTokenSource != null)
            {
                WriteLog("Forever-StopProcessing");

                cancellationTokenSource.Cancel();
            }
            else
            {
                WriteLog("Forever-StopProcessing-Ignored");
            }
        }

        private void WriteLog(string message)
        {
            using (StreamWriter sw = File.AppendText(LogFile))
            {
                sw.WriteLine(message);
            }
        }
    }
}
