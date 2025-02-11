# Design-and-Verification-of-a-Round-Robin-Based-Interconnect

The idea is to design and verify an interconnect that uses a round-robin arbiter to handle memory access requests from multiple masters. For now, I’m considering two masters, but I might scale it later. I’ve attached a block diagram to make it easier to understand.

---
![image](https://github.com/user-attachments/assets/12facb33-2a43-4c27-8805-b82baa5156f8)

## Why This Project?
The main reason I picked this project is that I know the basics of SystemVerilog and UVM, but I feel like only by applying them in a project I’ll really understand how to use them effectively and learn them in depth. So, this project is more of a learning experience for me.

Since the design is simple, I chose the **AMBA APB protocol**, which isn't just a random bundle of signals—it is a bundle of signals with specific logic and operational rules. APB works well for straightforward, low-speed transactions.

---

## Breakdown of the Project

1. **Design the APB protocol blocks** (like the master and slave).
2. **Verify these blocks using UVM**.
3. **Build a round-robin arbiter** to handle requests from multiple masters.
4. **Verify the arbiter using UVM**.
5. **Integrate everything** by combining the APB protocol blocks and the arbiter into an interconnect (essentially, a wrapper).
6. **Add two masters to the interconnect** (these are just black boxes that send requests; no internal logic is needed).
7. **Include a memory block preloaded with data**.
   - The idea is to verify if the interconnect can fetch data from memory and send it correctly to the masters.

---

## Project Goals
- Verify the functionality of the entire system using UVM.
- Ensure the protocol and arbitration logic work as expected.

This is the current plan, but I’m sure I’ll run into gaps or areas for improvement as I start implementing it.
