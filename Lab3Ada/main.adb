with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer;
                      Producers_Count : in Integer; Consumers_Count : in Integer) is
      Storage : List;
      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

      Item_Count : Natural := 0;

      task type Producer is
         entry Start(Item_Numbers : in Integer; Producer_Number: in Integer);
      end Producer;

      task type Consumer is
         entry Start(Item_Numbers : in Integer; Consumer_Number: in Integer);
      end Consumer;

      task body Producer is
         Item_Numbers : Integer;
         Producer_Number : Integer;
      begin
         accept Start (Item_Numbers : in Integer; Producer_Number: in Integer) do
            Producer.Item_Numbers := Item_Numbers;
            Producer.Producer_Number := Producer_Number;
         end Start;

         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Item_Count := Item_Count + 1;

            Storage.Append ("item " & Item_Count'Img);
            Put_Line ("Producer " & Producer_Number'Img & " produced item " & Item_Count'Img);

            Access_Storage.Release;
            Empty_Storage.Release;
         end loop;

      end Producer;

      task body Consumer is
         Item_Numbers : Integer;
         Consumer_Number : Integer;
      begin
         accept Start (Item_Numbers : in Integer; Consumer_Number: in Integer) do
            Consumer.Item_Numbers := Item_Numbers;
            Consumer.Consumer_Number := Consumer_Number;
         end Start;

         for i in 1 .. Item_Numbers loop
            Empty_Storage.Seize;
            delay 1.0;
            Access_Storage.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("Consumer " & Consumer_Number'Img & " consumed " & item);
            end;

            Storage.Delete_First;

            Access_Storage.Release;
            Full_Storage.Release;
         end loop;

      end Consumer;

      Producers : array(1 .. Producers_Count) of Producer;
      Consumers : array(1 .. Consumers_Count) of Consumer;
   begin
      for I in 1..Producers_Count loop
         declare
            Items : Integer := Item_Numbers / Producers_Count;
         begin
            if I = Producers_Count then
               Items := Item_Numbers - (i - 1) * (Item_Numbers / Producers_Count);
            end if;
            Producers(I).Start(Items, I);
         end;
      end loop;

      for I in 1..Consumers_Count loop
         declare
            Items : Integer := Item_Numbers / Consumers_Count;
         begin
            if I = Consumers_Count then
               Items := Item_Numbers - (i - 1) * (Item_Numbers / Consumers_Count);
            end if;
            Consumers(I).Start(Items, I);
         end;
      end loop;
   end Starter;

begin
   Starter (3, 10, 4, 5);
end Main;
