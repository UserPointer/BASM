import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.file;
import std.ascii : isWhite, isAlpha;


class BVM {
private:
   ubyte[256] memory;

   int ax, bx, cx, dx;

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
            memory[ax] = 0x00;

            string reg = parts[1];
            string val = parts[2];

            int value;

            if(val.startsWith("#0x")) {
               value = to!int(val[3..$], 16);
            } else if(val.startsWith('$')) {
               value = to!int(val[1..$]);
            }

            switch(reg) {
               case "ax": ax = value; break;
               case "bx": bx = value; break;
               case "cx": cx = value; break;
               case "dx": dx = value; break;
               default:
                  writeln("Unknown register: ", reg);
            }

            AssigningTheValueByTheRegister();
         }

         else {
            throw new Exception("Error: Unknown instruction/diricative");
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
         throw new Exception("Error: ", e.msg);
    }
}
