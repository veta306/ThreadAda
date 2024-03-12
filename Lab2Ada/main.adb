with Ada.Text_IO; use Ada.Text_IO;
procedure Main is
   length : constant integer := 1000;
   thread_num : constant integer := 4;
   arr : array(1..length) of integer;

   procedure Init_Arr is
   begin
      for i in 1..length loop
         arr(i) := i;
      end loop;
      arr(length/2) := -1000;
   end Init_Arr;

   function part_min(start, finish : in integer) return integer is
      min : integer := integer'last;
      index : integer := 1;
   begin
      for i in start..finish loop
         if arr(i) < min then
            min := arr(i);
            index := i;
         end if;
      end loop;
      return index;
   end part_min;

   protected part_manager is
      procedure set_part_min(index : in Integer);
      entry return_min(min: out Integer);
   private
      tasks_count : Integer := 1;
      minIndex : Integer := 1;
   end part_manager;
   protected body part_manager is
      procedure set_part_min(index : in integer) is
      begin
         if arr(index) < arr(minIndex) then
            minIndex := index;
         end if;
         tasks_count := tasks_count + 1;
      end set_part_min;
      entry return_min(min: out integer) when tasks_count = thread_num is
      begin
         min := minIndex;
      end return_min;
   end part_manager;

   task type starter_thread is
      entry run(start_index, finish_index : Integer);
   end starter_thread;
   task body starter_thread is
      index : Integer := 1;
      start, finish : Integer;
   begin
      accept run(start_index, finish_index : Integer) do
         start := start_index;
         finish := finish_index;
      end run;
      index := part_min(start, finish);
      part_manager.set_part_min(index);
   end starter_thread;

   procedure parallel_min is
      min: Integer := 1;
      threads : array(1..thread_num) of starter_thread;
   begin
      for i in 1..thread_num loop
         threads(i).run((i - 1) * length / thread_num, i * length / thread_num);
      end loop;
      part_manager.return_min(min);
      Put_Line("Index: "&min'Image&" Value: "&arr(min)'Image);
   end parallel_min;
begin
   Init_Arr;
   parallel_min;
end Main;
