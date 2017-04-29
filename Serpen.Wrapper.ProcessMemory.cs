using System;
using System.Runtime.InteropServices;

namespace Serpen.Wrapper {
public class ProcessMemory {
	
	public const uint VirtualMemoryRead = 0x00000010;
    public const uint VirtualMemoryWrite = 0x00000020;

	[DllImport("kernel32.dll", SetLastError = true)]
	public static extern bool ReadProcessMemory(
		IntPtr hProcess,
		IntPtr lpBaseAddress,
		[Out] byte[] lpBuffer,
		int dwSize,
		out IntPtr lpNumberOfBytesRead
	);
	
	[DllImport("kernel32.dll",SetLastError = true)]
	public static extern bool WriteProcessMemory(
		IntPtr hProcess,
		IntPtr lpBaseAddress,
		byte[] lpBuffer,
		int nSize,
		out IntPtr lpNumberOfBytesWritten
	);
	
	[DllImport("kernel32.dll", SetLastError = true)]
	public static extern IntPtr OpenProcess(
		uint processAccess,
		bool bInheritHandle,
		int processId
	);
	
	
	
	[DllImport("kernel32.dll", SetLastError=true)]
	[System.Runtime.ConstrainedExecution.ReliabilityContractAttribute(System.Runtime.ConstrainedExecution.Consistency.WillNotCorruptState, System.Runtime.ConstrainedExecution.Cer.Success)]
	[System.Security.SuppressUnmanagedCodeSecurity]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool CloseHandle(IntPtr hObject);
}
}