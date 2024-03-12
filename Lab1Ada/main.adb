with Ada.Text_IO;

procedure Main is
   Can_Stop : Boolean := False;
   pragma Atomic(Can_Stop);

   task type Break_Thread;
   task type Main_Thread is
      entry Start(Id: Integer; Step: Long_Long_Integer);
   end Main_Thread;

   task body Break_Thread is
   begin
      delay 10.0;
      Can_Stop := True;
   end Break_Thread;

   task body Main_Thread is
      Sum : Long_Long_Integer := 0;
      Elements : Long_Long_Integer := 0;
      Task_Id: Integer;
      Task_Step: Long_Long_Integer;
   begin
      accept Start (Id :Integer; Step : Long_Long_Integer) do
         Task_Id := Id;
         Task_Step := Step;
      end Start;
      loop
         Sum := Sum + Elements * Task_Step;
         Elements := Elements + 1;
         exit when Can_Stop;
      end loop;

      Ada.Text_IO.Put_Line("Thread: " & Task_Id'Img & " Sum: " & Sum'Img & " Count: " & Elements'Img);
   end Main_Thread;

   bt1: Break_Thread;
   Threads : array(1..4) of Main_Thread;
begin
   for I in 1..Threads'Length loop
      Threads(I).Start(I, 1);
   end loop;
end Main;
