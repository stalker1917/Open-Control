// By Stalker1917  LGPL 3.0

Unit AiManager;

interface
uses TimeManager,Finance,ControlConsts,StdCtrls,Graphics,SysUtils,AreaManager;



var
  LogMemo : TMemo;
  Plems : Array[1..NPlayers] of TColor;   //TEnemy
  TekSami : Integer;

type THangar=record
  X,Y:Byte;
  Hangar : PAngar;
end;


  
type TBase=record  //Поробовать сюда добавить ангары
  Base : PAreaB;
  X,Y : Byte;
  Miners,NMiners : TConstRes; //Nminers - количество шахт, в том числе и строящихся.
  Hangars : Array of THangar; 
  Avia : Array of TBuilding;
end;

PBase = ^TBase;

type TStackofBases=Object  //Возможно также сформировать стек зданий для уменьшения размера сохранений
  Data : Array of TBase;
  procedure AddBase(var B : TBase);
  procedure DestroyBase(N:Integer);
  function  FindBase(Base:PAreaB):Integer;
  procedure Load(var F:TBFile);
  procedure Save(var F:TBFile);
  procedure RefreshMiners(N:Integer);
  procedure RefreshHangars(X,Y,N:Integer);
  procedure RefreshAvia(X,Y,N:Integer); 
end;

PStackofBases = ^TStackofBases;

TPlaneControl=record
  Number : Integer; //Номер в самолётах, если выпущен. Если нет-то позиция в ангаре. 
  Base   : Integer; //Номер базы, если в базе
  X,Y    : Integer; //Положение ангара на базе.
  Event  : Boolean; //На задании или нет. 
  //OnBuild : Boolean; //Ещё строиться! 
end;

TPlaneArray = Array of TPlaneControl;

type TAiTriggers = class(TObject)
  Player     : Byte;
  Bank       : PBank;
  Events     : PStackOfEvent;
  Bases      : PStackofBases;
  Areas      : TStackofArea;
  //Tриггеры
  N_Planes : Array[1..C_MaxPlane] of TPlaneArray;
  Procedure AiTurn;
  Procedure PlaneToSky(Stype:Byte;Pos:Integer);
  procedure Economics;
  procedure ToWar; 
  function Build(var Base :TBase; const Cost:TConstRes;const BTime:TTimeRecord; BType:byte;X1,Y1:Integer; Target:Byte=0):Boolean;  // Строим что-нибудь//100-cамолёт
  function BuildNewPlane(SType:Integer):Boolean;
  //procedure CheckHangar(N:Byte); //Число событий по постройке+число смолётов сравниваем с местами в ангаре  N-номер базы  //Мо
  procedure CreatePlaneEvent(Extype:Byte;N:Integer);
  procedure InitAreas(Stype:Byte;N:Integer);
  function FindPlane(var N:Integer):Integer;
  procedure DeletePlane(Stype,N:Integer);// Удалить самолёт по его номеру в массвиве.
  Function  AreaX(N:Integer) :Byte;
  Function  AreaY(N:Integer) :Byte;
  Function  PlaneX(Stype,N:Integer) :Byte;
  Function  PlaneY(Stype,N:Integer) :Byte;
  procedure DestroyBase(DBase : PAreaB);
  procedure Surrender;
  procedure UpdateRes(Time:Integer);
  procedure Load(var F:TBFile);
  procedure Save(var F:TBFile);
  Constructor Create(N:Byte);

  Destructor Destroy;
 
end;

var
Base : Tbase;
BankofBases : array [1..NPlayers]  of  TStackofBases;
BankofTrigers: array [1..NPlayers]  of  TAiTriggers;


Procedure SetHouses(area2:PAreaB; SetMain:Boolean=False); 
Procedure AddTime(AddTime:Int64;Force:Boolean);
Procedure SolveEvent(N:Integer) ;
Procedure PutLog(S:String);

//Сейчас процедура неуниверсальная , работает только для 1
function XYTOStr(const X,Y:byte):String;
Function IsMine(const X,Y:byte; area2: PAreaB):Boolean; Overload;
Function IsMine(N:Byte):Boolean; Overload;
Function IsAvia(const X,Y:byte; area2: PAreaB):Boolean;
Function IsHangar(const X,Y:byte; area2: PAreaB):Boolean;

Function GetRegen(X,Y,i:byte):Integer;
procedure NewBase(X,Y,N:Byte;OnlyMainBase:Boolean=False);
Function  CoordToSec(A:Integer):Integer;
Function  SecToCoord(A:Integer):Integer;
Function  GetLn(const A:TSamolet):Double;
procedure SolvePlanes(ATime:Int64);
procedure PlaneToSky(const Base:TBase; var Samolet:PSamolet);
Function  GetRegime(Stype : Byte):Byte;
Procedure DeletePlane(Player,N:Integer);
Function AddPlane:Integer;
Procedure SetFlyEvent(Player,TX,Ty,N:Integer;Hang:Boolean=False;AddTime:Integer=0);


implementation
function TStackofBases.FindBase;
var i:Integer;
begin
result := -1;
for i:=0 to High(Data) do
  if Data[i].Base=Base then result := i;
end;

procedure TStackofBases.AddBase;
begin
  SetLength(Data,Length(Data)+1);
  Data[High(Data)] := B;
  RefreshMiners(High(Data));
  //(High(Data));
end;

procedure TStackofBases.Save;
var i,j,k :SmallInt;
begin
  k :=Length(Data);
  BlockWrite(F,k,SizeOf(SmallInt));
  for k := 0 to High(Data) do
    begin
      BlockWrite(F,Data[k].X,1);
      BlockWrite(F,Data[k].Y,1);
      j := Length(Data[k].Hangars);
      BlockWrite(F,j,SizeOf(SmallInt));
      for j := Low(Data[k].Hangars) to High(Data[k].Hangars) do
        begin
          BlockWrite(F,Data[k].Hangars[j],SizeOf(THangar));
          BlockWrite(F,Data[k].Hangars[j].Hangar[1],SizeOf(PSamolet)*6);
          for i := 1 to HangarHigh do
            if Data[k].Hangars[j].Hangar[i]<>nil then BlockWrite(F,Data[k].Hangars[j].Hangar[i]^,SizeOf(TSamolet));//then  BlockWrite(F,area[1,1],SizeOf(TSamolet))
                                                //else  BlockWrite(F,Data[k].Hangars[j].Hangar[i]^,SizeOf(TSamolet));

        end;
      AreaBSave(F,Data[k].Base^);
      j := Length(Data[k].Avia);
      BlockWrite(F,j,SizeOf(SmallInt));
      BlockWrite(F,Data[k].Avia[0],SizeOf(TBuilding)*j);
      BlockWrite(F,Data[k].NMiners[0],SizeOf(TConstRes));
      //BlockWrite(F,SizeOf(TAreaB));
    end;
end;

procedure TStackofBases.Load;   //СДелать в соотвествии с Save.
var i,j,k:SmallInt;
PustSam:TSamolet;
begin
  BlockRead(F,k,SizeOf(SmallInt));
  SetLength(Data,k);
  for k := 0 to High(Data) do
    begin
      BlockRead(F,Data[k].X,1);
      BlockRead(F,Data[k].Y,1);
      BlockRead(F,j,SizeOf(SmallInt));
      SetLength(Data[k].Hangars,j);
      New(Data[k].Base);
      for j := Low(Data[k].Hangars) to High(Data[k].Hangars) do
        begin
          BlockRead(F,Data[k].Hangars[j],SizeOf(THangar));
          Data[k].Hangars[j].Hangar := @Data[k].Base[Data[k].Hangars[j].X,Data[k].Hangars[j].Y].Angar;
          BlockRead(F,Data[k].Hangars[j].Hangar[1],SizeOf(PSamolet)*6);
          for i := 1 to HangarHigh do
            if Data[k].Hangars[j].Hangar[i]<>nil then  //BlockRead(F,PustSam,SizeOf(TSamolet))
              begin
                New(Data[k].Hangars[j].Hangar[i]);
                BlockRead(F,Data[k].Hangars[j].Hangar[i]^,SizeOf(TSamolet));
              end;
            //else
        end;
      //BlockRead(F,Base,SizeOf(TAreaB));
      AreaBLoad(F,Data[k].Base^);
      Area[Data[k].X,Data[k].Y].areab := Data[k].Base;
      BlockRead(F,j,SizeOf(SmallInt));
      SetLength(Data[k].Avia,j);
      BlockRead(F,Data[k].Avia[0],SizeOf(TBuilding)*j);
      if CurrSaveVersion>0 then BlockRead(F,Data[k].NMiners[0],SizeOf(TConstRes));
      RefreshMiners(k);
    end;
end;

procedure TStackofBases.RefreshMiners;
var i,j,X,Y : Integer;
area2 : PAreaB; 
begin
  if (N<0) and (N>High(Data)) then exit;
  area2 := Data[N].Base;
  for I := 1 to 4 do Data[N].Miners[i] := 0;
  for I := 1 to LBaseArea  do
    for j := 1 to LBaseArea  do
      if {(area2[i,j].plm>3) and (area2[i,j].plm<8)} IsMine(i,j,area2) then Data[N].Miners[area2[i,j].plm-3]:=Data[N].Miners[area2[i,j].plm-3]+BaseMine; //Часовая добыча
  X := Data[N].X;
  Y := Data[N].Y;
   for I := 1 to 4 do if (area[X,Y].Regeneration) and (Data[N].Miners[i]>GetRegen(X,Y,i)) then Data[N].Miners[i]:= GetRegen(X,Y,i);
end;

procedure TStackofBases.RefreshHangars;
begin
  if (N<0) and (N>High(Data)) then exit;
  if Data[N].Base[X,Y].plm<>3 then exit;
  SetLength(Data[N].Hangars,Length(Data[N].Hangars)+1);
  Data[N].Hangars[High(Data[N].Hangars)].X:=X;
  Data[N].Hangars[High(Data[N].Hangars)].Y:=Y;
  Data[N].Hangars[High(Data[N].Hangars)].Hangar := @Data[N].Base[X,Y].Angar;
end;

procedure TStackofBases.DestroyBase;
begin
  Dispose(Data[N].Base);
  area[Data[N].X,Data[N].Y].plm := 0;
  area[Data[N].X,Data[N].Y].areab := nil;
  if N<High(Data)  then Data[N] := Data[High(Data)];
  SetLength(Data,Length(Data)-1);
end;

procedure TStackofBases.RefreshAvia;
begin
  if (N<0) and (N>High(Data)) then exit;
  if Data[N].Base[X,Y].plm<>2 then exit;
  SetLength(Data[N].Avia,Length(Data[N].Avia)+1);
  Data[N].Avia[High(Data[N].Avia)].X:=X;
  Data[N].Avia[High(Data[N].Avia)].Y:=Y;
end;


//------------Независимые-----------
Procedure SetHouses(area2:PAreaB; SetMain:Boolean=False);  //Здесь это локальная переменная , вроде как работает для основателя базы
var l,m : Integer;
begin
  for l := 1 to 25 do
    for m := 1 to 25 do
      begin
        area2[l,m].clr := $00AAAA;
        area2[l,m].plm := 0;
        area2[l,m].HitPoints := 0;
      end;
   area2[12,12].clr := BuildCols[1];
   area2[12,12].plm := 1;
   area2[12,12].HitPoints :=H_Main; 
   if not SetMain then
     begin
       area2[14,12].clr := BuildCols[2];
       area2[10,12].clr := BuildCols[3];
       area2[10,10].clr := BuildCols[4];
       area2[10,14].clr := BuildCols[5];
       area2[14,14].clr := BuildCols[6];
       area2[14,10].clr := BuildCols[7];
       area2[14,12].plm := 2;
       area2[10,12].plm := 3;
       area2[10,10].plm := 4;
       area2[10,14].plm := 5;
       area2[14,14].plm := 6;
       area2[14,10].plm := 7;
     end;
end;

Procedure ResPlanes(OldTime:Int64);
var RTime : Int64;
i:Integer;
begin
 Rtime := Int64ToRtime(Timestamp,OldTime);
 if Rtime>0  then  for i := 1 to NPlayers do BankofTrigers[i].UpdateRes(Rtime); //UpdateRes(i,Rtime); //Добавление ресурсов
 SolvePlanes(Timestamp-OldTime);
end;

Procedure AddTime;
var
MinEvents:Byte;
TimeEvent,ManagerStamp,Planestamp:Int64;
begin
  ManagerStamp := TimeStamp;
  repeat 
    MinEvents := GetMinEvents;
    TimeEvent := BankofEvents[MinEvents].GetEvent.EventTime;
    Planestamp := Timestamp;
    if (MinEvents=0) or (TimeEvent>ManagerStamp+AddTime) then
      begin
        TimeStamp:=ManagerStamp+AddTime;
        ResPlanes(Planestamp);
      end
    else 
      begin
        if TimeEvent>Timestamp then TimeStamp:= TimeEvent;
        ResPlanes(Planestamp);//SolvePlanes(Timestamp-Planestamp);
        SolveEvent(MinEvents);
        //if MinEvents>1 then AiTurn(MinEvents);
        if (MinEvents=1)  then
          if (not Force) then exit
          else 
        else if (BankofTrigers[MinEvents]<>nil) then BankofTrigers[MinEvents].AiTurn;   
      end;

  until TimeStamp>=ManagerStamp+AddTime;
end;



Procedure SolvePlanes;
var i,j:Integer;
CoordXD,CoordYD:DOuble;
VecX,VecY:Double;
Ln : Double;
//X1,Y1:Integer;
begin
//ATime
  if ATime<=0 then exit;
  for i := 0 to Length(Samolets)-1 do 
    if Samolets[i]<> nil then  
      With Samolets[i]^ do
        if (TarX<>CoordX) or (TarY<>CoordY) then    //Или по X или по Y одинаковые координаты.
          begin
            Ln := GetLn(Samolets[i]^);//sqrt(sqr(TarX-CoordX)+sqr(TarY-CoordY));
            if Ln<0.1 then continue;
            CoordXD:= CoordX;
            CoordYD:= CoordY;
            VecX :=(TarX-CoordX)/Ln;
            VecY :=(TarY-CoordY)/Ln;
            for j:=0 to Atime do
              begin
                if (abs(VecX)<0.01) or ((TarX-CoordX)/VecX>0) then CoordXD := CoordXD + VecX*Velocites[Stype];
                if (abs(VecY)<0.01) or ((TarY-CoordY)/VecY>0) then CoordYD := CoordYD + VecY*Velocites[Stype];
                CoordX :=  Round(CoordXD);
                CoordY :=  Round(CoordYD);
                inc(area[CoordToSec(CoordX),CoordToSec(CoordY)].Timerasv[plm]);
              end;

          end
        else area[CoordToSec(CoordX),CoordToSec(CoordY)].Timerasv[plm] := area[CoordToSec(CoordX),CoordToSec(CoordY)].Timerasv[plm] + ATime;
        //Пока разведовательная способность у всех 100% , но это надо исправить.      
end;

Procedure SolveEvent;   //Номер игрока
var
Event : TEvent;
Angar : PAngar;
i,j,k,Nbase: Integer;
RTime : Int64;
Base : PBase;
//X,Y   : Byte;
begin
Event := BankofEvents[N].GetEvent;
Nbase := BankofBases[N].FindBase(area[Event.X,Event.Y].areab);
if NBase>=0 then Base := @BankofBases[N].Data[Nbase];
//SolvePlanes(Timestamp-OldStamp); //Изменение координат полёта самолётов
case Event.EventType of
  1:  //Постройка завода
    begin
      //Base.Base := ;
      i := Base.Base[Event.X1,Event.Y1].plm;
      if i>=128 then i := i - 128; //+Добавить цвет
      if N=1 then PutLog(Int64ToString(TimeStamp)+' Построено здание в квадрате '+XYTOStr(Event.X,Event.Y));
      if i>0 then Base.Base[Event.X1,Event.Y1].clr := BuildCols[i];
      Base.Base[Event.X1,Event.Y1].plm := i;
      Base.Base[Event.X1,Event.Y1].Regime := 0;
      if IsMine(i) then  BankofBases[N].RefreshMiners(Nbase);
      if IsHangar(Event.X1,Event.Y1,Base.Base)then
        begin
          BankofBases[N].RefreshHangars(Event.X1,Event.Y1,Nbase);   //Если ангар, добавляем в список ангаров.
          for j := Low(Base.Base[Event.X1,Event.Y1].Angar) to High(Base.Base[Event.X1,Event.Y1].Angar) do
            Base.Base[Event.X1,Event.Y1].Angar[j] := nil;
        end;
      if IsAvia(Event.X1,Event.Y1,Base.Base) then BankofBases[N].RefreshAvia(Event.X1,Event.Y1,Nbase); //Если аВиазавод, добавляем в список авиазаводов.
    end;
  2:  //Постройка самолёта
    begin
       k:=100;  //Если так и останется значит в ангаре нет места.
       for  j:=0 to High(Base.Hangars) do
       begin
         Angar :=  Base.Hangars[j].Hangar;//  Нужно именно ссылку передать
       i := 1; //Позиция в ангаре начинается с 1-го элемента
       repeat
         if Angar[i]=nil then
           begin
             New(Angar[i]);
             Angar[i].Stype := Base.Base[Event.X1,Event.Y1].Regime;
             Angar[i].HitPoints := 10;
             Angar[i].InBase := True;
             Angar[i].Toplivo := 300;
             Angar[i].plm := area[Event.X,Event.Y].plm;
             k := i;
             I :=-1;
             break;
           end;
        inc(i)
       until (i>6); // Исправить на много ангаров!
       if i<0 then  break;
       end;
       
      Base.Base[Event.X1,Event.Y1].Regime := 0;
      if N=1 then
         if k<100 then PutLog(Int64ToString(TimeStamp)+' Построен самолёт в квадрате '+XYTOStr(Event.X,Event.Y))
                  else PutLog(Int64ToString(TimeStamp)+' Нет места в ангаре '+XYTOStr(Event.X,Event.Y));
      If (BankofTrigers[N]<>nil) and (k<100) then
        begin
          SetLength(BankofTrigers[N].N_Planes[Angar[k].Stype],Length(BankofTrigers[N].N_Planes[Angar[k].Stype])+1);
          with  BankofTrigers[N].N_Planes[Angar[k].Stype][High(BankofTrigers[N].N_Planes[Angar[k].Stype])]  do
            begin
              Event := False;
              Base := Nbase;
              X := {AiManager.}BankofBases[N].Data[Nbase].Hangars[j].X; //Здесь нельзя base ставить, т.к. with
              Y := {AiManager.}BankofBases[N].Data[Nbase].Hangars[j].Y;
              Number := -k;
            end;
        end; 
    end;
    3:
      begin
        i := BankofEvents[N].GetPlaneNumber;
        if Samolets[i]<> nil then
          With Samolets[i]^ do
            begin
              CoordX := TarX;
              CoordY := TarY; 
              k:=i;
              //BankofTrigers[N].FindPlane(j)<0 then break;
              j := BankofTrigers[N].FindPlane(k);
              if j>=0 then BankofTrigers[N].N_Planes[Stype,k].Event := False; //Cбрасываем событие
              if (Stype=2) then   // Упрощённая игра. Бомбардирощик долетел, уменьшил хит-поинты у базы и выпилился.
              if (area[Event.X,Event.Y].plm>0) and (area[Event.X,Event.Y].plm<>N) then
                begin
                  area[Event.X,Event.Y].areab[12,12].HitPoints := area[Event.X,Event.Y].areab[12,12].HitPoints - H_Bomb;
                  DeletePlane(N,i);
                  if area[Event.X,Event.Y].areab[12,12].HitPoints<=0 then BankofTrigers[area[Event.X,Event.Y].plm].DestroyBase(area[Event.X,Event.Y].areab);
                end;
              if (Stype=3) and (bombs=1) then    //Тип основатель базы и приказ основать базу , а не просто лететь в квадрат.
              if area[Event.X,Event.Y].plm=0 then
                begin
                  NewBase(Event.X,Event.Y,plm,True);
                  if N=1 then PutLog(Int64ToString(TimeStamp)+' Успешно основана база в квадрате '+XYTOStr(Event.X,Event.Y));
                  DeletePlane(N,i);
                  
                 //Записать - база основана успешно.
                end
              else
                begin
                  bombs := 0; //Приказ изменён на "лететь в точку"
                  if N=1 then PutLog(Int64ToString(TimeStamp)+' Ошибка основания базы в квадрате '+XYTOStr(Event.X,Event.Y));
                //Записать: Ошибка основания базы.
                end;
              end;  
      end; 
    5: 
      begin
        i := BankofEvents[N].GetPlaneNumber; //Берём номер самого последнего самолёта в банке. Это можно т.к. последний номер с наименьшим временем
        j := BankofTrigers[N].FindPlane(i);
        //if j<0 then  break;
        if j>=0 then BankofTrigers[N].N_Planes[j,i].Event := False; //Сбросили событие
        if N=1 then PutLog(Int64ToString(TimeStamp)+' Успешно проведена разведка в квадрате '+XYTOStr(Event.X,Event.Y));
      end;  
  end;
//end;
BankofEvents[N].DeleteEvent;   
OldStamp := TimeStamp;  
end;

procedure DeletePlane;
var
Stype,Num:Integer;
begin
  if Samolets[N] = nil then exit;//Удалаем уже удалённый самолёт
  if Samolets[N].plm<>Player then exit; //Удаляем чужой самолёт
  Samolets[N] := nil;
  Num := N;
  Stype := BankofTrigers[Player].FindPlane(Num);
  if (Stype>0) and (Stype<=C_MaxPlane) then BankofTrigers[Player].DeletePlane(Stype,Num);
end;

Function AddPlane;
var i,H:Integer;
begin
  H := High(Samolets);
  for i:=0 to  H do
    if Samolets[i]=nil then
      begin
        result := i;
        exit;
      end; 
  SetLength(Samolets,H+2);
  result := H+1;    
end;

function XYTOStr;
begin
  result := chr(ord('a')+X-1) + IntToStr(Y);
end;

Procedure PutLog(S:String); //Добавляем строку в лог действий игрока
begin
  LogMemo.Lines.Add(S);
end;


Function IsMine(const X,Y:byte; area2: PAreaB):Boolean;
begin
  result := (area2[X,Y].plm>3) and (area2[X,Y].plm<8);
end;

Function IsMine(N:Byte):Boolean;
begin
  result := (N>3) and (N<8);
end;

function IsHangar;
begin
  result := (area2[X,Y].plm=3);
end;

function IsAvia;
begin
  result := (area2[X,Y].plm=2);
end;

Function GetRegen(X,Y,i:byte):Integer;
begin
  result := Round(area[X,Y].Res[i]/I_Regeneration);
end;



procedure NewBase;
var i:Integer;
begin
    area[X,Y].clr:=Plems[N];
    area[X,Y].plm:=N;
    New(area[X,Y].areab);  //На самом деле базы есть.
    SetHouses(area[X,Y].areaB,OnlyMainBase);
    
    Base.X := X;
    Base.Y := Y;
    Base.Base  := area[X,Y].areaB;
    if not OnlyMainBase then //Связываем анграры базы и территории.
      begin
        SetLength(Base.Hangars,1);
        SetLength(Base.Avia,1);
        Base.Hangars[0].X := 10;
        Base.Hangars[0].Y := 12; 
        Base.Hangars[0].Hangar := @area[X,Y].areaB[10,12].Angar;
        for I := Low(Base.Hangars[0].Hangar^) to High(Base.Hangars[0].Hangar^)  do  Base.Hangars[0].Hangar[i] := nil;
        Base.Avia[0].X := 14;
        Base.Avia[0].Y := 12;
        for i := 1 to 4 do Base.NMiners[i]:=1;
      end
    else
      begin
        SetLength(Base.Hangars,0);  //А то из прошлой базы состояние перейдёт.
        SetLength(Base.Avia,0);
        for i := 1 to 4 do Base.NMiners[i] :=0;
      end;
    BankofBases[N].AddBase(Base);
    area[X,Y].Timerasv[N]:=TimeToResources+1;
end;

function CoordToSec;
begin
  result := Trunc(A/SectorDlinna)+1;
  if result>Larea then
    result := Larea;
end;

function SecToCoord;
begin
  result := Round(SectorDlinna*(A-0.5));
end;

function GetLn;
begin
  with a do result := sqrt(sqr(TarX-CoordX)+sqr(TarY-CoordY));
end;

procedure PlaneToSky;
var
N,M:Integer;
begin
  //SetLength(Samolets,Length(Samolets)+1);
  M := AddPlane;
  Samolets[M] := Samolet;  //Выпускаемый самолёт=aнгаровский самолёт
  with Samolets[M]^ do
    begin
      CoordX := SecToCoord(Base.X);
      CoordY := SecToCoord(Base.Y);
      TarX := CoordX;
      TarY := CoordY;
    end;
  Samolet:= nil;
  N:=area[Base.X,Base.Y].plm;
  //if N>1 then
  BankofTrigers[N].PlaneToSky(Samolets[M].Stype,M);
end;

function GetRegime;
begin
  if Stype<C_MaxPlane then Result := C_Regimes[Stype]
                      else Result := 0;
end;

procedure SetFlyEvent;
begin
with Samolets[N]^ do
  begin
    if Hang then
      begin
        TarX := CoordX;
        TarY := CoordY; 
      end
    else
      begin
        TarX := Tx;
        TarY := Ty;      
      end;
    //Bombs := 0
    //Создать событие
    Event.X := CoordToSec(TarX);
    Event.Y := CoordToSec(TarY);
    if Hang then 
      begin
        Event.EventType := 5;
        Event.EventTime :=Timestamp+ AddTime;
      end
    else 
      begin
        Event.EventType := 3;
        Event.EventTime :=Timestamp+ Round(GetLn(Samolets[N]^)/Velocites[Stype]);
      end;
    SetPlaneNumber(Event,N);
    BankofEvents[Player].AddEvent(Event);
   // BankofEvents[Player].SetPlaneNumber(N); //Портит данные
    if (not Hang) and (Stype=3) and (area[Event.X,Event.Y].plm=0) and (area[Event.X,Event.Y].Timerasv[Player]>TimeToBase)  then     //ecли основатель и базу можно основать
      if plm>1 then Bombs := 1;    //Основываем базу, если игрок >1
  end;  
end;

//----------Икусственный интеллект -------
Constructor TAiTriggers.Create;
var i:Integer;
begin
  inherited Create;
  Player     := N;
  Bank       := @Banks[N];
  Events     := @BankofEvents[N]; 
  Bases      := @BankofBases[N];  
  Areas.RightMode := True;
  Areas.Angle     := 0;
  Areas.Over      := False;
  Areas.Player    := Player;
  for i := 1 to 3 do SetLength(N_Planes[i],0);
  ///
end;

function TAiTriggers.AreaX;
begin
  result := Areas.Data[N].X;
end;
function TAiTriggers.AreaY;
begin
  result := Areas.Data[N].Y;
end;

function TAiTriggers.PlaneX;
begin
  if N_Planes[Stype,N].Number<0 then
    result := Bases.Data[N_Planes[Stype,N].Base].X
  else
    result := CoordToSec(Samolets[N_Planes[Stype,N].Number].CoordX);
end;
function TAiTriggers.PlaneY;
begin
  if N_Planes[Stype,N].Number<0 then
    result := Bases.Data[N_Planes[Stype,N].Base].Y
  else
    result := CoordToSec(Samolets[N_Planes[Stype,N].Number].CoordY);
end;

Destructor TAiTriggers.Destroy;
begin
  inherited Destroy;
end; 
Procedure TAiTriggers.AiTurn;
var i:Integer;
b:Boolean;
begin
  //Разведка

  for i:=0 to High(N_Planes[1]) do
    if (N_Planes[1][i].Event=False) then
      if i=0 then CreatePlaneEvent(0,0) //Если нет задания , оправляем на задание
             else CreatePlaneEvent(1,i);
  if Length(N_Planes[1])<(2+Length(Bases.Data)) then b:=BuildNewPlane(1)  //Количество разведчиков = 2 + количество баз.
                                                else b := True;
  if not b then exit; // Нет денег на постройку новых разведчиков или ангаров к ним. 
  //На каждой базе нужен авиазавод. Нет таковского? И не строиться? Срочно строить! И хотя бы один ангар.
  for i := 0 to High(Bases.Data) do
   if (Length(Bases.Data[i].Avia)<1) and (Bases.Data[i].Base[14,12].plm=0) then
     begin
       b := Build(Bases.Data[i],C_AviaFactory,T_AviaFactory,2,14,12); //Строим авиазавол
       if not b then exit;
     end;
  Economics;
  ToWar;
end;

Function TAiTriggers.BuildNewPlane;
var i,j,k:Integer;
N_Hang,N_pl:Integer;
NoFactory  : Boolean;
begin
  //Для каждой базы проверить - есть ли место в ангаре. 
  N_Hang := 0;
  N_Pl := 0;
  result := true;
  for i := 0 to Events._High do
    begin
      if  Events.Data[i].EventType=2 then  //Если на задании строительство самолёта
      begin
        inc(N_Pl);
        j := Bases.Findbase(area[Events.Data[i].X,Events.Data[i].Y].AreaB);
        if j>=0 then
          with Bases.Data[j]  do
            if Base[Events.Data[i].X1,Events.Data[i].Y1].Regime=SType then exit; //Уже начали строить.
      end;
    end;
  for i := 1 to 3 do N_Pl := N_Pl + Length(N_Planes[i]);
  for i := 0 to High(Bases.Data) do N_Hang := N_Hang + 6*Length(Bases.Data[i].Hangars);
  if N_Hang > N_Pl then
    begin
       NoFactory  := true;    //Авиазавод загружен? Значит вываливаемся с true;
       for i := 0 to High(Bases.Data) do
        begin
         N_Hang := High(Bases.Data[i].Avia);  //Число доступных авиазаводов -1
         if  (N_Hang>0) and (Stype=3) then N_Hang :=0; //Гражданские самолёты только на заводе 1!
         for j := 0 to N_Hang   do
           if Bases.Data[i].Base[Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y].Regime=0  then
             begin
               NoFactory := False;  //Есть авиазавод для строительства
                 case Stype of 
                  1: result := Build(Bases.Data[i],C_Watcher,T_Watcher,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,0);
                  2: result := Build(Bases.Data[i],C_Bomber ,T_Bomber ,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,1);
                  3: result := Build(Bases.Data[i],C_Constructor,T_Constructor,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,2);
             end; 
        end;     
       if (Nofactory) and (Stype=2) then  //Нет завода, а нужен бомбардировщик
       begin
         for j := 0 to High(Bases.Data) do
          begin
           N_Hang := Length(Bases.Data[i].Avia)+1;  //Если есть в центре, начинаем со второго завода.
           if N_Hang<LBaseArea then
           //if N then
             if {(Length(Bases.Data[j].Avia)<2)} {and} (Bases.Data[j].Base[N_Hang,8].plm=0) then
               begin
                 result := Build(Bases.Data[j],C_AviaFactory,T_AviaFactory,2,N_Hang,8,1); //Строим авиазавод из военного бюджета
                 exit;
               end;
          end;
       end;       
    end;
   end
  else
    begin
      //Нигде нет - строим ангар. 
      N_Hang := 1000; 
      k:=0;
      for i := 0 to Events._High do
       begin
         if  Events.Data[i].EventType=1 then
          begin
            j:=Bases.Findbase(area[Events.Data[i].X,Events.Data[i].Y].AreaB);
            if (j<0) then continue;//Если не находиться, значит это вообще не та база
            if (Bases.Data[j].Base[Events.Data[i].X1,Events.Data[i].Y1].plm=103) then exit; //Уже начали строить
          end;
       end;
      //Если нигде не строиться ангар, то начинаем строить.
      for i := 0 to High(Bases.Data) do
        if Length(Bases.Data[i].Hangars)<N_Hang then  //Строим там где меньше всего ангаров
          begin
            N_Hang := Length(Bases.Data[i].Hangars);
            k:=i;
          end;
      result := Build(Bases.Data[k],C_Hangar,T_Hangar,3,N_Hang+1,9,GetRegime(Stype)); //Строим ангары в ряд  - режим в отличие от типа самолёта. Работает, если меньше трёх.
    end;
end;

Procedure TAiTriggers.Economics;
var i,j:Integer;
b:Boolean;
begin
  //-------Шахты
  //Для каждой базы проверяем - равна ли выработка шахт уровню регенерации.
  b := True;
  for j:=4 downto 1 do  //Сначала строим фиолетовые шахты, а потом уже и остальное
    for i:=0 to High(Bases.Data) do
      if Bases.Data[i].NMiners[j]*BaseMine<GetRegen(Bases.Data[i].X,Bases.Data[i].Y,j) then    //Если меньше, то строим ещё шахту
        begin
          if Bases.Data[i].NMiners[j]+1<=LBaseArea then //Нельзя поставить больше 25 шахт.
            b := Build(Bases.Data[i],C_Mine,T_Mine,3+j,Bases.Data[i].NMiners[j]+1,15+j,2); //Мирная постройка
          if not b then break;
        end;

  //-------Основатели базы
  for i:=0 to High(N_Planes[3]) do
    if N_Planes[3][i].Event=False then CreatePlaneEvent(3,i); //Если нет задания , оправляем на задание

  if not b then  exit;    //Не можем построить - на выход.
  b:=BuildNewPlane(3);  //Количество разведчиков = 2 + количество баз. 
  //
  //Строим основатель базы на авиазаводе 1
     //Если на базе нет места -строим ангар. 

end;

Procedure TAiTriggers.ToWar;
var i:Integer;
b:Boolean;
begin
  //-------Бомбардировщики
  //Всем бомбардировщикам базы даём задание
    for i:=0 to High(N_Planes[2]) do
    if N_Planes[2][i].Event=False then CreatePlaneEvent(2,i); //Если нет задания , оправляем на задание
        //Строим бомбардировщик на авиазаводе 1
     //Если на базе нет места -строим ангар.
     //Если авиазавод 1 занят, строим авиазавод 2
     // 
    b:=BuildNewPlane(2);
end;

Procedure TAiTriggers.InitAreas;
//var X,Y:Byte;
begin
    Areas.AddData(PlaneX(Stype,N),PlaneY(Stype,N));
end;

Procedure TAiTriggers.CreatePlaneEvent;  //Stype,N
var
Target : Integer;
TarTIme : Integer;
Stype : Integer;
begin
  Stype := Extype;
  if Stype=0 then Stype := 1; //Приводим расширенный тип к массиву.

  if Length(Areas.Data)=0 then  InitAreas(Stype,N);
  case Extype of
    0 : 
      begin
        Areas.NextNewWatch; //Первый самолёт
        Target := High(Areas.Data);
        if Areas.GetX>=250 then  //Если всё разведали, то по второй схеме разведуем всё
          begin
            Extype := 1;
            Target := Areas.NextWatch;
          end;
      end;  
    1 : Target := Areas.NextWatch;
    2 : Target := Areas.NextTarget;
    3 : Target := Areas.NextBase;
  end;  
  //if Stype<2  //Если Target совпадает с целью создаём событие висения(и вылетаем)
  if (Stype<2) and (N_Planes[Stype,N].Number>=0) and (PlaneX(Stype,N)=AreaX(Target)) and (PlaneY(Stype,N)=AreaY(Target)) then
    begin
      if Extype=0 then TarTime := TimeToBase
                  else TarTime := TimeToResources;
      TarTime := TarTime-area[AreaX(Target),AreaY(Target)].Timerasv[Player];
      if TarTime<0 then TarTime := 1;             
      SetFlyEvent(Player,0,0,N_Planes[Stype,N].Number,True,TarTime);   //Создаём висячее событие.
      N_Planes[Stype,N].Event := True;
      exit;
    end;
  //Фактически else к той ветке.
  if Target>=0 then  //Если Targer и самолёт не запущен, то запускаем
    begin
      if N_Planes[Stype,N].Number<0 then 
        begin
          Base := Bases.Data[N_Planes[Stype,N].Base];
          //Здесь считаем позицию на базе                       f
          AiManager.PlaneToSky(Base,Base.Base[N_Planes[Stype,N].X,N_Planes[Stype,N].Y].Angar[-N_Planes[Stype,N].Number]);
        end;
      SetFlyEvent(Player,SecToCoord(AreaX(Target)),SecToCoord(AreaY(Target)),N_Planes[Stype,N].Number);   //Создаём событие полёта к цели
      N_Planes[Stype,N].Event := True;
    end;
  //Если Targer = -1 и самолёт есть, отправляем на базу(в будущем)
end;

Procedure TAiTriggers.PlaneToSky;
var i:Integer;
begin
  for i:=0 to High(N_Planes[Stype]) do
    begin
      if N_Planes[Stype][i].Number>=0 then continue;
      if Bases.Data[N_Planes[Stype][i].Base].Base[N_Planes[Stype][i].X,N_Planes[Stype][i].Y].Angar[-N_Planes[Stype][i].Number]=nil then //Если самолёт только что взлетел.
        begin
          N_Planes[Stype][i].Number := Pos;//High(Samolets); //Не High,а тот, который получился
          break;
        end;         
    end;    
end;

Function TAiTriggers.FindPlane;
var i,j:Integer;
begin
  result := -1;
  for i:=1 to C_MaxPlane do
    for j:=0 to High(N_Planes[i]) do
      if N_Planes[i,j].Number = N then
      begin
        result := i;
        N := j;
        exit;
      end;
      //break;    //Нужен break из двух циклов.
end;

Procedure TAiTriggers.DeletePlane;
begin
  if N<High(N_Planes[Stype]) then N_Planes[Stype,N] := N_Planes[Stype,High(N_Planes[Stype])];
  SetLength(N_Planes[Stype],Length(N_Planes[Stype])-1);
end;


function TAiTriggers.Build;
begin
  result := false;
  if Base.Base=nil then exit;
  BankStructure.Fill(Cost);
  if Banks[Player].SpendResource(Target,BankStructure)=0 then
    begin
      If btype<100 then
        begin
          Base.Base[X1,Y1].plm := Btype+128; //+128- Значит строится
          Base.Base[X1,Y1].clr := $808080;
          if IsMine(Btype)  then inc(Base.NMiners[btype-3])
        end
      else Base.Base[X1,Y1].Regime := btype - 100;
      Event.EventType := 1+(btype div 100);
      Event.EventTime := TimeStamp + TimeToInt64(Btime);
      Event.X  := Base.X;
      Event.Y  := Base.Y;
      Event.X1 := X1;
      Event.Y1 := Y1;
      Events.AddEvent(Event);
      Base.Base[X1,Y1].TimeToPusk := Event.EventTime;//3600*24*5;
      result :=True;
    end;
end;

Procedure TAiTriggers.DestroyBase;
var N:Integer;
begin
  N := Bases.FindBase(DBase);
  Bases.DestroyBase(N);
  if Length(Bases.Data)=0 then  Surrender;
end;

Procedure TAiTriggers.Surrender;
var i:Integer;
begin
  Events.Destroy;
  for i := 0 to High(Samolets) do AiManager.DeletePlane(Player,i);
  for i := 1 to 3 do  SetLength(N_Planes[i],0);
    //if Samolets^[i]. the
end;

procedure TAiTriggers.Save;
var i,j,k :SmallInt;
begin
   Bank.Save(F);
   Events.Save(F);
   Bases.Save(F);
   Areas.Save(F);
   for i := 1 to C_MaxPlane do
     begin
       k := Length(N_planes[i]);
       BlockWrite(F,k,SizeOf(SmallInt));
       BlockWrite(F,N_planes[i,0],Sizeof(TPlaneControl)*k);
     end;
end;

procedure TAiTriggers.Load;
var i,j,k :SmallInt;
begin
  Bank.Load(F);
  Events.Load(F);
  Bases.Load(F);
  Areas.Load(F);
    for i := 1 to C_MaxPlane do
     begin
       BlockRead(F,k,SizeOf(SmallInt));
       SetLength(N_planes[i],k);
       BlockRead(F,N_planes[i,0],Sizeof(TPlaneControl)*k);
     end;
end;

Procedure TAiTriggers.UpdateRes;
var
i,j:Integer;
Res : Integer;
begin
  for i:=1 to 4 do
    begin
      Res:=0;
      for j:=0 to High(Bases.Data) do  Res:=Res+Bases.Data[j].Miners[i]; //Пока здесь хрень
      Bank.AddResource(i,Res*Time);
    end;
end;


begin
end.