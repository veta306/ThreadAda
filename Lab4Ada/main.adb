with Ada.Text_IO; use Ada.Text_IO;
with GNAT.Semaphores; use GNAT.Semaphores;

procedure Main is
   Num_Philosophers : constant := 5;
   Num_Forks : constant := 5;

   task type Philosopher is
      entry Start(Id : Integer);
   end Philosopher;

   Forks : array (1..Num_Forks) of Counting_Semaphore(1, Default_Ceiling);

   task body Philosopher is
      Id : Integer;
      Id_Left_Fork, Id_Right_Fork : Integer;
   begin
      accept Start (Id : in Integer) do
         Philosopher.Id := Id;
      end Start;
      Id_Left_Fork := Id;
      Id_Right_Fork := Id rem Num_Forks + 1;
      for I in 1..10 loop
         Put_Line("Philosopher " & Id'Img & " thinking " & I'Img & " time");

         if Id_Left_Fork < Id_Right_Fork then
            Forks(Id_Left_Fork).Seize;
            Put_Line("Philosopher " & Id'Img & " took left fork");
            Forks(Id_Right_Fork).Seize;
            Put_Line("Philosopher " & Id'Img & " took right fork");
         else
            Forks(Id_Right_Fork).Seize;
            Put_Line("Philosopher " & Id'Img & " took right fork");
            Forks(Id_Left_Fork).Seize;
            Put_Line("Philosopher " & Id'Img & " took left fork");
         end if;

         Put_Line("Philosopher " & Id'Img & " eating" & I'Img & " time");

         Forks(Id_Left_Fork).Release;
         Put_Line("Philosopher " & Id'Img & " put left fork");

         Forks(Id_Right_Fork).Release;
         Put_Line("Philosopher " & Id'Img & " put right fork");
      end loop;
   end Philosopher;

   Philosophers : array (1..Num_Philosophers) of Philosopher;
begin
   for I in Philosophers'Range loop
      Philosophers(I).Start(I);
   end loop;
end Main;

