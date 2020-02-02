// By Stalker1917  LGPL 3.0

unit AreaManager;


interface
uses Finance,ControlConsts,Graphics;
type
TSamolet = record
  Stype : Byte;
  CoordX,CoordY : Int64; //Текущие координаты ,в 1/1000 от нормальных
  TarX,TarY : Int64;  //Цель пути
  HitPoints : SmallInt;
  Bombs : Byte;
  Toplivo : SmallInt; //Уменьшается каждую минуту.
  InBase : Boolean;
  plm : byte;
end;
PSamolet = ^TSamolet;



TAngar =  Array[1..HangarHigh] of PSamolet;
PAngar = ^TAngar;

TfieldB = record
  plm : Byte;
  clr : TColor;
  Regime : Byte;
  HitPoints : Smallint;
  TimeToPusk : Int64;
  Angar : TAngar;
end;

TCropField = Record
  clr : TColor;
  Regime : Byte;
  HitPoints : Smallint;
  TimeToPusk : Int64;
end;

TAreaB = array[1..LBaseArea,1..LBaseArea] of TfieldB;
PAreaB = ^TAreaB;
TPlmB  = array[1..LBaseArea,1..LBaseArea] of Byte;


Tfield = record
  plm : Byte;
  clr : TColor;
  Res : TRes;
  Timerasv : Array[1..NPlayers] of Int64; //За час определяет базу , за 1,5 суток - полная разведка ресурсов. Считается в секундах.  Лучше сделать массивом, т.к. важна разведка для каждого из игроков
  areab : PAreaB;
  Regeneration : Boolean;
end;

TBuilding = record
  X,Y:Byte;
end;

TAreaData = TBuilding;

type TStackofArea = object
  Data : Array of TAreaData;
  RightMode : Boolean;
  Angle     : Byte;
  Over      : Boolean;
  Player    : Byte;
  procedure Turn(Mode:Boolean=False);
  procedure Left;
  procedure Right;
  function  GoForward:Boolean;
  procedure AddData(X,Y:Byte);
  Function  GetX :Byte;
  Function  GetY :Byte;
  procedure NextNewWatch;
  procedure Load(var F:TBFile);
  procedure Save(var F:TBFile);
  function  NextWatch : Integer;
  function  NextTarget : Integer;
  function  NextBase : Integer;
end;

var
area:array[1..LArea,1..LArea] of Tfield;
Samolets : Array of PSamolet;
CheatMode : Boolean = False;

procedure AreaBSave(var F:TBFile; var Area2 : TAreaB);
procedure AreaBLoad(var F:TBFile; var Area2 : TAreaB);

implementation

//----------TStackofArea-----------

function TStackofArea.GetX;
begin
  result := Data[High(Data)].X;
end;
function TStackofArea.GetY;
begin
  result := Data[High(Data)].Y;
end;



procedure TStackofArea.Turn;
begin
  if (RightMode xor Mode) then Right
                          else Left;
end;
procedure TStackofArea.Right;
begin
  Angle := (Angle+3) mod 4;
end;

procedure TStackofArea.Left;
begin
  Angle := (Angle+1) mod 4;
end;

function  TStackofArea.GoForward;
var X,Y:Integer;
begin
  X := GetX;
  Y := GetY;
  case angle of
    0:
      begin
        inc(X);
        if X>LArea then result := False
                   else result := True;
      end;
    1:
      begin
        dec(Y);
        if Y<1     then result := False
                   else result := True;
      end;
    2:
      begin
        dec(X);
        if X<1     then result := False
                   else result := True;
      end;
    3:
      begin
        inc(Y);
        if Y>LArea then result := False
                   else result := True;
      end;
  end;
  if (result) then
    if area[X,Y].Timerasv[Player]>TimeToBase then result := False
                                             else AddData(X,Y);
end;

procedure TStackofArea.NextNewWatch;
var i,X,y:Integer;
begin
  X := GetX;
  Y := GetY;
  if X>250 then  exit; //Всё хватит.

  if Area[X,Y].Timerasv[Player]<TimeToBase then exit; // Уже и так всё нормально.
  if not Over then
  begin
  Turn;
  for i := 1 to 3 do
    if GoForward then break
    else
      begin
        if i=2 then RightMode := not RightMode;
        Turn(i=1);
      end;
  if i>3 then  Over := True
         else  exit;
  end;
//Over;
  i:=0;
  repeat
  inc(X);
  if X>LArea then
    begin
      X := 1;
      inc(Y);
    end;
  if Y>LArea then Y:=1;
  inc(i);
  until (Area[X,Y].Timerasv[Player]<TimeToBase) or (i>LArea*LArea); //Нашли ещё неразведанную
  //Через 9 дней может быть бесконечный цикл потому что всё уже разведано.
  if (i<=LArea*LArea) then AddData(X,Y)
                      else AddData(255,255);
end;

procedure TStackofArea.AddData;
begin
  SetLength(Data,Length(Data)+1);
  Data[High(Data)].X := X;
  Data[High(Data)].Y := Y;
end;
Function TStackofArea.NextWatch;
var i:Integer;
begin
  result := -1;
    for i := 0 to High(Data) do
      if (area[Data[i].X,Data[i].y].Timerasv[Player]>TimeToBase) then
       if (area[Data[i].X,Data[i].y].plm=0) and (area[Data[i].X,Data[i].y].clr<>$FFFF00) then    //Нет базы и не вода.
        if (area[Data[i].X,Data[i].y].Timerasv[Player]<TimeToResources) then
          begin
            result := i;
            break;
          end;
end;
Function TStackofArea.NextTarget;
var i:Integer;
begin
  result := -1;
  for i := 0 to High(Data) do
   if (area[Data[i].X,Data[i].y].plm>0) and (area[Data[i].X,Data[i].y].plm<>Player) then
     begin
       result := i;
       break;
     end;
end;
Function TStackofArea.NextBase;
var i,max,maxi:Integer;
begin
  maxi := -1;
  max  := GetCost(C_HalfMaximum);
  for i := 0 to High(Data) do
     if (area[Data[i].X,Data[i].y].Timerasv[Player]>TimeToResources) and (area[Data[i].X,Data[i].y].plm=0)  then
      if GetCost(area[Data[i].X,Data[i].y].Res)>max then
        begin
          maxi := i;
          max := GetCost(area[Data[i].X,Data[i].y].Res);
        end;
  result := maxi;
end;

Procedure TStackofArea.Load;
var i:SmallInt;
begin
  BlockRead(F,i,2);
  SetLength(Data,i);
  for I := Low(Data) to High(Data) do BlockRead(F,Data[i],SizeOf(TAreaData));
end;

Procedure TStackofArea.Save;
var i:SmallInt;
begin
  i := Length(Data);
  BlockWrite(F,i,2);
  for I := Low(Data) to High(Data) do BlockWrite(F,Data[i],SizeOf(TAreaData));
end;

//------------Независимые-----------
procedure AreaBSave;
var
PlmB : TPLmB;
CField : TCropField;
i,j : Integer;
begin
  for I := 1 to LBaseArea do
    for j := 1 to LBaseArea do
      PlmB[i,j] := Area2[i,j].plm;
  BlockWrite(F,PlmB,SizeOf(TPlmB));
  for I := 1 to LBaseArea do
    for j := 1 to LBaseArea do
      if PlmB[i,j]>0 then
        begin
          CField.clr := Area2[i,j].clr;
          CField.Regime := Area2[i,j].Regime;
          CField.HitPoints := Area2[i,j].HitPoints;
          CField.TimeToPusk := Area2[i,j].TimeToPusk;
          BlockWrite(F,CField,SizeOf(CField));
        end;

end;
procedure AreaBLoad;
var
PlmB : TPLmB;
CField : TCropField;
i,j : Integer;
begin
  BlockRead(F,PlmB,SizeOf(TPlmB));
  for I := 1 to LBaseArea do
    for j := 1 to LBaseArea do
      begin
        Area2[i,j].plm :=  PlmB[i,j];
        if PlmB[i,j]>0 then
          begin
            BlockRead(F,CField,SizeOf(CField));
            Area2[i,j].clr := CField.clr;
            Area2[i,j].Regime := CField.Regime;
            Area2[i,j].HitPoints := CField.HitPoints;
            Area2[i,j].TimeToPusk := CField.TimeToPusk;
          end;
      end;
end;

end.
