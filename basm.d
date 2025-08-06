import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.file;
import std.ascii : isWhite, isAlpha;


class BVM {
private:
   ubyte[256] memory;

   short ax, bx, cx, dx;

public:
   this() {
      memory[] = 0;

      ax = bx = cx = dx = 0;
   }

   void NexDump() {
      for(int i = 0; i < 256; i += 8) {
         writef("%04X: ", i);

         for(int j = 0; j < 8; ++j) {
            writef("%02X ", memory[i + j]);
         }

         write(" ");

         writeln();
      } 
   }

   void RegistersStatus() {
      writeln("Registers: ");
      writefln("AX: %04X (%d)", ax, ax);
      writefln("BX: %04X (%d)", bx, bx);
      writefln("CX: %04X (%d)", cx, cx);
      writefln("DX: %04X (%d)", dx, dx);
   }

   void AssigningTheValueByTheRegister() {
      if(ax >= 0 && ax < 256) {
         memory[ax] = 0x00;

         memory[ax] = cast(ubyte)ax;
      }

      if(bx >= 0 && bx < 256) {
         memory[bx] = 0x00;

         memory[bx] = cast(ubyte)bx;
      }

      if(cx >= 0 && cx < 256) {
         memory[cx] = 0x00;

         memory[cx] = cast(ubyte)cx;
      }

      if(dx >= 0 && dx < 256) {
         memory[dx] = 0x00;
               
         memory[dx] = cast(ubyte)dx;
      }
   }

   void executionOfInstructions(string[] lines) {
      foreach(line; lines) {
         auto trimmed = strip(line);

         if(trimmed.empty) {
            continue;
         }

         auto parts = split(trimmed);

         if(parts.empty) {
            continue;
         }

         if(parts[0] == ";") {
            if(parts[1] != "\n") {
               continue;
            }

            continue;
         }

         if(parts[0] == "mov" && parts.length >= 3) {
            string dest = parts[1];
            string val = parts[2];

            short value;

            if(val.startsWith("#0x")) {
               value = to!short(val[3..$], 16);
            } else if(val.startsWith('$')) {
               value = to!short(val[1..$]);
            } else {
               throw new Exception("Incorrect syntax. Use $decimal or #0xhex");
            }

            if(dest.startsWith("[") && dest.endsWith("]")) {
               string addrStr = dest[1..$-1];
               short addr;

               if(addrStr.startsWith("#0x")) {
                  addr = to!short(addrStr[3..$], 16);
               } else if(addrStr.startsWith('$')) {
                  addr = to!short(addrStr[1..$]);
               } else {
                  throw new Exception("Incorrect syntax. Use $decimal or #0xhex");
               }

               if(addr >= 0 && addr < 256) {
                  memory[addr] = cast(ubyte)value;
               } else {
                  throw new Exception("Memory address out of range");
               }
            }
            
            else if(val.startsWith("[") && val.endsWith("]")) {
               string addrStr = val[1..$-1];
               short addr;

               if(addrStr.startsWith("#0x")) {
                  addr = to!short(addrStr[3..$], 16);
               } else if(addrStr.startsWith('$')) {
                  addr = to!short(addrStr[1..$]);
               } else {
                  throw new Exception("Incorrect syntax. Use $decimal or #0xhex");
               }

               switch(dest) {
                  case "ax": ax = memory[addr]; break;
                  case "bx": bx = memory[addr]; break;
                  case "cx": cx = memory[addr]; break;
                  case "dx": dx = memory[addr]; break;
                  default:
                     throw new Exception("Unknown destination: " ~ dest);
               }
            } else {
               switch(dest) {
                  case "ax": ax = value; break;
                  case "bx": bx = value; break;
                  case "cx": cx = value; break;
                  case "dx": dx = value; break;
                  default:
                     throw new Exception("Unknown destination: " ~ dest);
               }
            }

            AssigningTheValueByTheRegister();
         }
      }
   }
}

void main(string[] args) {
   if (args.length < 2) {
      writefln("Usage: %s <filename.asm>", args[0]);

      return;
   }

   try {
      string[] lines = splitLines(readText(args[1]));
        
      auto bvm = new BVM();  

      bvm.executionOfInstructions(lines);
        
      writeln("Memory dump:");

      bvm.NexDump();
      bvm.RegistersStatus();
    } catch(Exception e) {
         stderr.writeln("Error: ", e.msg);
    }
}