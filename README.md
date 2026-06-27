# XKERNEL – The Native XOS Exokernel [XSPEC-0004]

**XKERNEL** is the central and official kernel of the **XOS** operating system. It’s entirely programmed in **16-bit pure x86 Assembly** under an **Exokernel** architecture.

## 🛠️ Core Philosophy v1.0

Unlike monolithic kernels (like Linux) or microkernels (like Minix), XKERNEL does not hide the hardware behind complicated software abstractions or POSIX/UNIX layers. Its sole goal is to deliver high performance.
1. **Securely multiplex hardware:** Ensure that applications have direct, raw access to physical resources, without any intermediaries.
2. **Providing a low-level API:** Offering minimal and essential hardware-related subroutines (for video, keyboard, disk, memory, and interrupts).
3. **Transfer control:** Delegate the management of complex abstractions to the user space libraries (`XLIB`).

## ⚙️ Initialization of Primary Subsystems

Upon receiving the execution jump from `XBOOT`, the kernel stabilizes the machine by executing instructions sequentially:
* **Video:** Direct TTY subroutines through register mapping.
* **Keyboard:** Handling of non-blocking interrupts for character input.
* **Timer:** Synchronizes the clock cycles of the CPU.
* **Interruptions:** The Interrupt Vector Table (IVT) is initialized to isolate system calls from other processes.

## 🚀 The Next Step in the Evolution of the Ecosystem

Once the basic initialization process is complete, XKERNEL proceeds directly to the **`EXIT`** initialization subsystem. This subsystem is responsible for mounting the **`EXFS`** file system and launching the **`XSH`** user interface.
