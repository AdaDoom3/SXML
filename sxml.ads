package SXML
   with SPARK_Mode
is

   type Node_Type is private;
   type Subtree_Type is array (Natural range <>) of Node_Type;

   function Is_Valid (Left, Right : Subtree_Type) return Boolean
   with
      Ghost;

   function Ampersand (Left, Right : Subtree_Type) return Subtree_Type
      renames "&";

   function "&" (Left, Right : Subtree_Type) return Subtree_Type
   with
      Pre => Is_Valid (Left, Right);

   Null_Tree : constant Subtree_Type;

   function E (Name     : String;
               Children : Subtree_Type := Null_Tree) return Subtree_Type;

   function A (Name  : String;
               Value : Integer) return Subtree_Type;

   function A (Name  : String;
               Value : Float) return Subtree_Type;

   function A (Name  : String;
               Value : String) return Subtree_Type;

   function To_String (Tree : Subtree_Type) return String;

private
   type Kind_Type is (Kind_Invalid,
                      Kind_Element_Open,
                      Kind_Element_Close,
                      Kind_Attr_Integer,
                      Kind_Attr_Float,
                      Kind_Attr_String);

   -- FIXME: The length should become a generic parameter
   type Name_Type is new String (1..100);
   Null_Name : constant Name_Type := (others => Character'Val (0));

   type Node_Type (Kind : Kind_Type := Kind_Invalid) is
   record
      Name : Name_Type;
      case Kind is
         when Kind_Invalid
            | Kind_Element_Open
            | Kind_Element_Close => null;
         when Kind_Attr_Integer =>
            Integer_Value : Integer;
         when Kind_Attr_Float =>
            Float_Value : Float;
         when Kind_Attr_String =>
            String_Value : Name_Type;
      end case;
   end record;

   Null_Node : constant Node_Type := (Kind => Kind_Invalid, Name => Null_Name);
   Null_Tree : constant Subtree_Type (1..0) := (others => Null_Node);

   function Is_Attr (Node : Node_Type) return Boolean;

   function Is_Valid (Left, Right : Subtree_Type) return Boolean
   is
      (if Is_Attr (Right (Right'First)) then
          Is_Attr (Left (Left'Last)) or
          Left (Left'Last).Kind = Kind_Element_Open);

   function To_String (Value : Float) return String;
   function To_String (Value : Integer) return String;


end SXML;
