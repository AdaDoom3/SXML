package body SXML
   with SPARK_Mode
is

   -------
   -- & --
   -------

   function "&" (Left, Right : Subtree_Type) return Subtree_Type
   is
      Len : constant Natural := Left'Length + Right'Length;
      Result : Subtree_Type (1 .. Len);
   begin
      Result (1 .. Left'Length) := Left;
      Result (Left'Length + 1 .. Result'Last) := Right;
      return Result;
   end "&";

   -------------
   -- To_Name --
   -------------

   function To_Name (Name : String) return Name_Type
   is
      Result : Name_Type := (others => Character'Val (0));
   begin
      for I in Name'Range
      loop
         Result (I) := Name (I);
      end loop;
      return Result;
   end To_Name;

   ---------------
   -- To_String --
   ---------------

   function To_String (Name : Name_Type) return String
   is
      Len : Natural := 0;
   begin
      loop
         exit when Len >= Name'Last or else Name (Len + 1) = Character'Val (0);
         Len := Len + 1;
      end loop;
      return String (Name (1 .. Len));
   end To_String;

   -------
   -- E --
   -------

   function E (Name       : String;
               Children   : Subtree_Type := Null_Tree) return Subtree_Type
   is
      Index : Natural;
   begin
      return Result : Subtree_Type (1 .. Children'Length + 2)
      do
         Result (Result'First) := (Kind => Kind_Element_Open, Name => To_Name (Name));
         Index := 2;
         for Child of Children
         loop
            Result (Index) := Child;
            Index := Index + 1;
         end loop;
         Result (Result'Last) := (Kind => Kind_Element_Close, Name => To_Name (Name));
      end return;
   end E;

   -------
   -- A --
   -------

   function A (Name  : String;
               Value : Integer) return Subtree_Type
   is
   begin
      return (1 => (Kind          => Kind_Attr_Integer,
                    Name          => To_Name (Name),
                    Integer_Value => Value));
   end A;

   -------
   -- A --
   -------

   function A (Name  : String;
               Value : Float) return Subtree_Type
   is
   begin
      return (1 => (Kind        => Kind_Attr_Float,
                    Name        => To_Name (Name),
                    Float_Value => Value));
   end A;

   -------
   -- A --
   -------

   function A (Name  : String;
               Value : String) return Subtree_Type
   is
   begin
      return (1 => (Kind         => Kind_Attr_String,
                    Name         => To_Name (Name),
                    String_Value => To_Name (Value)));
   end A;

   --------------
   -- Text_Len --
   --------------

   function Text_Len (Tree : Subtree_Type) return Natural
   is
      Result : Natural := 0;
   begin
      for E of Tree
      loop
         Result := Result + To_String (E.Name)'Length;
         case E.Kind
         is
            when Kind_Element_Open =>
               Result := Result + 2;
            when Kind_Element_Close =>
               Result := Result + 3;
            when Kind_Attr_Integer =>
               Result := Result + E.Integer_Value'Img'Length + 4;
            when Kind_Attr_String =>
               Result := Result + To_String (E.String_Value)'Length + 4;
            when Kind_Attr_Float =>
               Result := Result + E.Float_Value'Img'Length + 4;
            when Kind_Invalid =>
               return 0;
         end case;
      end loop;
      return Result;
   end Text_Len;

   ---------------
   -- To_String --
   ---------------

   function To_String (Tree : Subtree_Type) return String
   is
      Position : Natural := 1;
      Is_Open  : Boolean := False;

      procedure Append (Result : in out String;
                        Data   :        String)
      is
      begin
         for C of Data
         loop
            Result (Position) := C;
            Position := Position + 1;
         end loop;
      end Append;

   begin
      return Result : String (1 .. Text_Len (Tree))
      do
         for I in Tree'Range
         loop
            case Tree (I).Kind
            is
               when Kind_Element_Open =>
                  if Is_Open
                  then
                     Is_Open := False;
                     Append (Result, ">");
                  end if;
                  Is_Open := True;
                  Append (Result, "<" & To_String (Tree (I).Name));
               when Kind_Element_Close =>
                  if Is_Open
                  then
                     Is_Open := False;
                     Append (Result, ">");
                  end if;
                  Append (Result, "</" & To_String (Tree (I).Name) & ">");
               when Kind_Attr_Integer =>
                  Append (Result, " " & To_String (Tree (I).Name) & "=""" & Tree (I).Integer_Value'Img & """");
               when Kind_Attr_String =>
                  Append (Result, " " & To_String (Tree (I).Name) & "=""" & To_String (Tree (I).String_Value) & """");
               when Kind_Attr_Float =>
                  Append (Result, " " & To_String (Tree (I).Name) & "=""" & Tree (I).Float_Value'Img & """");
               when Kind_Invalid =>
                  Result := (others => Character'Val (0));
                  return;
            end case;
         end loop;
      end return;
   end To_String;

end SXML;
