namespace JwlMediaWin.Core
{
    using System;
    using System.ComponentModel;
    using System.Diagnostics;
    using System.IO;
    using System.Reflection;

    /// <summary>
    /// Blocks or restores JW Library's internet access via a dedicated Windows Firewall
    /// rule set, by invoking the PowerShell scripts bundled under the "Scripts" folder.
    /// Leaves all other applications (Zoom, browsers, etc.) unaffected.
    /// </summary>
    public static class InternetBlocker
    {
        private const string ScriptFileName = "ToggleJwlInternetCore.ps1";

        /// <summary>
        /// Checks whether JW Library's internet access is currently blocked.
        /// Read-only; does not require elevation.
        /// </summary>
        /// <returns>true if blocked, false if enabled, null if the state could not be determined.</returns>
        public static bool? IsBlocked()
        {
            var output = RunPowerShell("-Action Status", elevated: false);
            if (output == null)
            {
                return null;
            }

            return output.Trim().Equals("Blocked", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Blocks or restores JW Library's internet access. Triggers a UAC elevation prompt.
        /// </summary>
        /// <param name="blocked">true to block internet access, false to restore it.</param>
        /// <returns>true if the change was applied; false if it failed or elevation was cancelled.</returns>
        public static bool SetBlocked(bool blocked)
        {
            var action = blocked ? "Block" : "Enable";
            return RunPowerShell($"-Action {action}", elevated: true) != null;
        }

        private static string GetScriptPath()
        {
            var dir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            return Path.Combine(dir ?? string.Empty, "Scripts", ScriptFileName);
        }

        private static string RunPowerShell(string arguments, bool elevated)
        {
            var scriptPath = GetScriptPath();
            if (!File.Exists(scriptPath))
            {
                return null;
            }

            var psi = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = $"-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"{scriptPath}\" {arguments}",
                UseShellExecute = elevated,
                CreateNoWindow = !elevated,
                RedirectStandardOutput = !elevated
            };

            if (elevated)
            {
                psi.Verb = "runas";
            }

            try
            {
                using (var process = Process.Start(psi))
                {
                    var output = elevated ? null : process.StandardOutput.ReadToEnd();
                    process.WaitForExit();

                    if (elevated)
                    {
                        return process.ExitCode == 0 ? "OK" : null;
                    }

                    return process.ExitCode == 0 ? output : null;
                }
            }
            catch (Win32Exception)
            {
                // the UAC elevation prompt was cancelled
                return null;
            }
        }
    }
}
