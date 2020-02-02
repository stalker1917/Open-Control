// By Stalker1917  LGPL 3.0
Unit Finance;

interface
uses ControlConsts;
const 
  HighRes = 4; //Число видов ресурсов 0- деньги
type
TConstRes  = Array[0..HighRes] of LongWord;
TResDouble = Array[0..HighRes] of Double;
TRes       = Array[1..HighRes] of SmallInt;
const

Stoimost : TConstRes = (1,7,14,22,39); //Стоимость каждого ресурса
C_Maximum : TRes  = (10000,5000,3333,2500);
C_HalfMaximum : TRes  = (5000,2500,1666,1250); 

//Самолёты
C_Watcher      : TConstRes = (800,5,5,5,5); //Стоимость самолёта
C_Bomber       : TConstRes = (1800,30,0,25,3); //Стоимость самолёта
C_Constructor  : TConstRes = (2000,30,0,20,10); //Стоимость самолёта
//Здания
C_AviaFactory  : TConstRes = (11500,0,0,0,0);
C_Hangar       : TConstRes = (6000,0,0,0,0);
C_Mine         : TConstRes = (4000,0,0,0,0);


type

TBankStructure = object
Data : Array[0..HighRes+1] of Integer; //0 - деньги, 5- общие деньги
procedure SolveSum;
procedure Fill(const Cost: TConstRes);
end;



TMoney = object //Это каждый ресурс
WarMoney,PeaceMoney : Integer;
WarPercent : Double;  //На самом деле доля, на процент
function SpentAll(money:Integer) :Integer; //Тратим из обоих бюджетов - если не потратили , то недостача
function SpentWar(money:Integer) :Integer;
function SpentPeace(money:Integer) :Integer;
function SpentAbstract(var Cash:Integer;Money:Integer):Integer;
function GetWarPart(Spend:Integer):Integer;
procedure AddCount(Count:Integer);
end;

TBank = Object
Data : Array [0..HighRes+1] of TMoney;
Procedure AddResource(N,Count:Integer);
Procedure Reset;
Function SpendResource(Regime:Byte; BankStructure : TBankStructure):Integer;
Function SpendRegime(Regime:Byte;N,Cost:Integer):Integer;
Procedure AddRegime(Regime:Byte;N,Cost:Integer);
Function CheckRegime(Regime:Byte;N:Integer):Integer;
Procedure SetWarPercent(Percent:Byte);  //В настоящий процентах.
procedure Load(var F:TBFile);
procedure Save(var F:TBFile);
End;

PBank = ^TBank;

var 
Banks : Array [1..NPlayers] of TBank;
BankStructure : TBankStructure;// Текущая структура.

Function LongSort(Res:TResDouble):TConstRes;
Function GetCost(Res:TRes):Integer;

implementation


//----------------------TBank-----
procedure  TBank.AddResource;
begin
  if (N>4) or (N<0) then exit;
  Data[N].AddCount(Count);
  Data[5].AddCount(Count*Stoimost[N]);
end; 



procedure  TBank.Reset;
var i:Integer;
begin
  for i:=1 to 5 do 
   begin
     Data[i].WarMoney := 0;
     Data[i].PeaceMoney := 0;
     Data[i].WarPercent := 0;
   end;
end; 

Function TBank.SpendRegime;
begin
  case Regime of
   0: result := Data[N].SpentAll(Cost);
   1: result := Data[N].SpentWar(Cost);
   2: result := Data[N].SpentPeace(Cost);
  end;
end; 

Procedure TBank.AddRegime;
begin
  case Regime of
   0: Data[N].AddCount(Cost);
   1: Data[N].WarMoney := Data[N].WarMoney +Cost;
   2: Data[N].PeaceMoney := Data[N].PeaceMoney +Cost;
  end;
end;

Function TBank.CheckRegime;
begin
  case Regime of
   0: result := Data[N].WarMoney+Data[N].PeaceMoney;
   1: result := Data[N].WarMoney;
   2: result := Data[N].PeaceMoney;
  end;
end; 


function  TBank.SpendResource;
var Debt,TekDebt,Active : Integer;
// TConstRes
Share,Hvost : TResDouble;
Sort : TConstRes;
i:Integer;
begin
Debt := 0;
result := SpendRegime(Regime,5,BankStructure.Data[5]);
if result<0 then exit;
for i:=0 to HighRes do
  begin
  TekDebt := -SpendRegime(Regime,i,BankStructure.Data[i]);
  if TekDebt>0 then
    begin
      Debt := Debt+TekDebt*Stoimost[i];
      AddRegime(Regime,i,TekDebt); //Добавляем, чтобы можно было потратить.
      SpendRegime(Regime,i,BankStructure.Data[i]);
    end; 
  end;
//Развёрстываем долг по оставшимcя ресурсам.
if Debt=0 then exit;
Active := 0; 
for i := 0 to HighRes do Active := Active + CheckRegime(Regime,i)*Stoimost[i]; 
for i := 0 to HighRes do Share[i] := (CheckRegime(Regime,i)*Stoimost[i])/Active;
//Доразверстать с учётом округления. 
for i:=0 to HighRes do
 begin
   Hvost[i] := Share[i]*Debt/Stoimost[i];
   TekDebt := Trunc(Hvost[i]);
   Hvost[i] := Hvost[i] - TekDebt;
   if SpendRegime(Regime,i,TekDebt) = 0 then Debt :=Debt-TekDebt*Stoimost[i];
 end;   
Sort := LongSort(Hvost);
for i:=0 to HighRes do
  begin
    if SpendRegime(Regime,Sort[i],1)  = 0 then  Debt := Debt-Stoimost[Sort[i]];
    if Debt<0 then break;
  end;
if Debt<0 then AddRegime(Regime,0,-Debt); //Минусовой долг прибавляем к деньгам 
// if Debt>0 - залогируем ситуацию  
end;

Procedure TBank.SetWarPercent;
var
i:byte;
begin
  if Percent>100 then Percent:=100;
  for i := 0 to HighRes+1 do Data[i].WarPercent := Percent/100; 
  
end;


//----------------------TBankStructure-----
procedure TBankStructure.SolveSum;
var i:Integer;
begin
  Data[HighRes+1] := Data[0];
  for i := 1 to HighRes do Data[HighRes+1] := Data[HighRes+1] + Data[i]*Stoimost[i];
end; 

procedure TBankStructure.Fill;
var i:Integer;
begin
  for i := 0 to HighRes do Data[i] := Cost[i];
  SolveSum;
end;

//----------------------TMoney----------------
procedure TMoney.AddCount;
var War:Integer;
begin 
  War := GetWarPart(Count);
  WarMoney := WarMoney + War;
  PeaceMoney := PeaceMoney + Count-War;    
end;

function TMoney.GetWarPart;
begin
 result := Round(WarPercent*Spend);
end;

function TMoney.SpentAbstract;
begin
  if Cash>=Money then 
    begin
      result := 0;
      Cash:=  Cash-Money;
    end
  else Result := Money-Cash;  //Сколько нам не хватает.
end;

function TMoney.SpentWar;
begin
  result := SpentAbstract(WarMoney,Money);
end;

function TMoney.SpentPeace;
begin
  result := SpentAbstract(PeaceMoney,Money);
end;

function TMoney.SpentAll;
var WarSp : Integer;
begin
  if (WarMoney+PeaceMoney)>= money then result :=0
  else result := (WarMoney+PeaceMoney)-money; //При нехватки денег выдаём отрицательный результат.
  if result=0 then
    begin
      WarSp := GetWarPart(money);
      if SpentWar(WarSp)=0 then
        begin
          Money := Money - WarSp;
          if SpentPeace(Money)>0 then  //Не хватило денег
            begin
              WarMoney := WarMoney - Money + PeaceMoney;
              PeaceMoney := 0;
            end; 
        end
     else
      begin
        PeaceMoney := PeaceMoney - Money + WarMoney;
        WarMoney := 0;   
      end;   
    end;
end;

//-------Независимые процедуры-------
Function LongSort; //Сортировка по наибольшим остаткам
var
i,j,k:Integer;
max : Double;
  begin  
    for i := 0 to HighRes do 
      begin 
        max := -1;
        for j := 0 to HighRes do
          begin 
            if Res[j]>Max then
              begin
                k:=j;
                Max := Res[j];
              end;                            
          end;
        Result[i] :=k;
        Res[k] := -1;  
      end;
  end;
Function GetCost;
var i:Integer;
begin
  result := 0;
  for i := 1 to HighRes do result := result + res[i]*stoimost[i];
end;

Procedure TBank.Load;
var i:Integer;
begin
  for I := Low(Data) to High(Data) do BlockRead(F,Data[i],SizeOf(TMoney));
end;

Procedure TBank.Save;
var i:Integer;
begin
  for I := Low(Data) to High(Data) do BlockWrite(F,Data[i],SizeOf(TMoney));
end;

begin
end.