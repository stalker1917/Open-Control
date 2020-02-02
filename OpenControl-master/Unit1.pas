{$A-}

// By Stalker1917  LGPL 3.0
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Math, ExtCtrls, ImgList,Unit2,Finance,ControlConsts,
  System.ImageList,TimeManager,AiManager,OCGraph,AreaManager, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Image1: TImage;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Timer1: TTimer;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Edit13: TEdit;
    Edit14: TEdit;
    ImageList1: TImageList;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    Edit15: TEdit;
    LeV: TLabeledEdit;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    RadioGroup3: TRadioGroup;
    LabeledEdit6: TLabeledEdit;
    Button3: TButton;
    Memo1: TMemo;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RadioGroup2Click(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RadioGroup3Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OutPutCost(const Cost :TConstRes);
    procedure OutPutBuilding(const s:String);
    procedure ShutDownShape;
    procedure OutPutStandart(const s:String);
    procedure OutPutMine(const s:String);
    procedure StartBuild(const Cost:TConstRes;const BTime:TTimeRecord; BType:byte);
    procedure Edit1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  //100-cамолёт
    procedure Edit2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  
    procedure Edit3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  
    procedure Edit4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  
    procedure Edit7MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  
    procedure ShapeRadius(N:Integer);
    procedure ShapesVisible(B:Boolean);
    procedure LeditsVisible(B:Boolean);
    procedure CLS;
    procedure ShapesPosition(Mode:Byte);
    procedure RadioGroup1Click(Sender: TObject);
    procedure SetTAHString(AHString : TAHStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;






const

  TimeRazvCoef : Array[1..4] of Single=(1,0.5,0.25,0.7); //Как хорошо разведывают самолёты
var
  Form1: TForm1;
  output:Text;
  textfile : File of Char;
  God : Byte = 22;
  Nas : Integer;
  Vs : Double;
  Raspr : Array[0..999] of Integer;
  Ub :Integer;
  UbObh :Integer;
  godv : Double;
  srgod : Double;
  ndel : Double;
  ndelold :Double;
  //cl :TColor;

  //---

  area2:PAreaB;

  Teki,Tekj : Byte;
  Okno : Byte;
  Tekbi,Tekbj : Byte;
  Samv  : Boolean = False;
  TekSam : PSamolet;
  F2Otkl : Byte = 0;
  Ledits : Array[1..6] of TLabeledEdit;
  Shapes : Array[1..4] of TShape;
  RadioArray : Array [1..HangarHigh] of Byte;
implementation
uses OKCANCL2;

{$R *.dfm}


Function TypeSamToStr(i:Byte):String;
begin
  case i of
   1:    result := 'Разведчик';
   2:    result := 'Бомбардировщик';
   3:    result := 'Основатель базы';
  end;
end;

procedure TForm1.OutPutBuilding;
begin
  RadioGroup1.Visible := False;
  Edit14.Text := 'Строящийся ' + s;
  RadioGroup2.Visible := False;
  //Shape1.Visible := False;
  //Shape2.Visible := False;
  //Shape3.Visible := False;
  //Shape4.Visible := False;
  ShapesVisible(False);
  Edit13.Visible := True;
  Edit13.Text := 'Осталось до конца строительства: ' +  Int64ToEnd(area2[Teki,Tekj].TimeToPusk); //IntToStr((area2[Teki,Tekj].TimeToPusk-TimeStamp) div (24*3600)) +' д.' + IntToStr(((area2[Teki,Tekj].TimeToPusk-TimeStamp) mod (24*3600)) div 3600) + ' ч.';
end;

procedure TForm1.SetTAHString;
var i:Integer;
begin
  Lev.EditLabel.Caption := AHString[0];
  for i:=1 to 2 do Ledits[i].EditLabel.Caption := AHString[i];
  RadioGroup3.Caption := AHString[High(AHString)];
end;

procedure TForm1.ShapesPosition(Mode: Byte);
var i:Integer;
begin
  case Mode of
    1: for I := Low(Shapes) to High(Shapes) do  //Открыт экран базы
      begin
        Shapes[i].Top := 700;
        Shapes[i].Left := 40*i-20; //20-60...
      end
    else for I := Low(Shapes) to High(Shapes) do //Стандартная позиция
      begin
        Shapes[i].Top := 386 - 27*(i mod 2);
        Shapes[i].Left := 16+128*(i div 3);
      end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var LenC:Integer; Buf:Char;
S:String; Spr:String;
i,j:Integer;
RealName : Boolean;
begin
case Okno of

0:

begin
if area[Teki,Tekj].areab=nil then exit; //Как-то неправильно вошли в базу , надо перезайти
if Samv then
  begin
    Samv := False;
    exit;
  end;
Okno := 1;
Edit9.Visible := False;
Edit10.Visible := False;
Edit11.Visible := False;
Edit12.Visible := False;
Edit13.Visible := False;
ShapesVisible(False);
Button1.Caption := 'Войти в здание';
ShapeRadius(1);
ShapesPosition(1);
Button4.Visible := False;
Button6.Visible := False;

TekBi := Teki;
TekBj := Tekj;
//exit;
//А почему после exit???
area2 := area[Teki,Tekj].areab;
progressBar1.Visible := True;
end;
1:
//if Okno=1 then
  begin
    Okno:=2;
    Button5.Enabled := False;
    Button1.Caption := 'Выйти в базу';
    case area2[Teki,Tekj].plm of
    2:  //Авиазавод
      begin
        Lev.Visible := True;
        SetTAHString(AS_AviaFactory);
        RadioGroup3.Visible := True;
        RadioGroup3.Items.Clear;
        for I := 1 to 3 do RadioGroup3.Items.Add(TypeSamToStr(i));
        Button3.Visible := True;
        if area2[Teki,Tekj].Regime>0 then
          begin
            RadioGroup3.ItemIndex := area2[Teki,Tekj].Regime-1;
            RadioGroup3.Enabled := False;
            Lev.EditLabel.Caption := 'Время осталось';
            Lev.Text := TimeToBuild(Int64ToTime(area2[Teki,Tekj].TimeToPusk-TimeStamp));
            Button3.Caption := 'Отменить производство';
          end
        else
         begin
           LeditsVisible(True);
           Lev.EditLabel.Caption := 'Время производства';
           RadioGroup3.Enabled := True;
           Button3.Caption := 'Начать постройку';
         end;

      end;
    3:   //Ангар
     begin
      RadioGroup3.Enabled := True;
      RadioGroup3.Visible := True;
      RadioGroup3.Items.Clear;
      Lev.Visible := True;
      LeditsVisible(False);
      LabeledEdit1.Visible := True;
      LabeledEdit2.Visible := True;
      SetTAHString(AS_Hangar);
     // i:=1;
      //while (i<6) and (area2[Teki,Tekj].Angar[i]<>nil) do
        //begin
      j := 1;
      with area2[Teki,Tekj] do
      for i := Low(Angar) to HangarHigh do
          if Angar[i]<>nil then
            begin
              RadioGroup3.Items.Add('Самолёт'+IntTOStr(i));
              RadioArray[j]:=i;
              inc(j);
            end;


         // inc(i);
        //end;
      Button3.Visible := True;
      Button3.Caption := 'Вылет';
     end;

    end;
  //  exit;
  end;
2:
  begin
    Okno:=1;
    Button5.Enabled := True;
    Button1.Caption := 'Войти в здание';
        Lev.Visible := False;
        LeditsVisible(False);
        RadioGroup3.Visible := False;
        Button3.Visible := False;
    Button2.Click;
  end;
end;
Button2Click(Sender);
end;

procedure TForm1.Button2Click(Sender: TObject);  //Обновить экран.
var i,j,k,m:Integer;
R  : TRect;
begin
case okno of
  0: Render;
  1: RenderBase(area2);
end;
R.Left:=1;
R.Right := 1000;
R.Top := 1;
R.Bottom := 1000;
Form1.Canvas.CopyRect(R,MainBmp.Canvas,R);
Form1.Edit15.Text := IntToStr(Banks[1].CheckRegime(0,5));
end;

procedure TForm1.OutPutCost;
var i : Byte;
begin 
  BankStructure.Fill(Cost);
  for i:=0 to HighRes+1 do Ledits[i+1].Text:= IntToStr(BankStructure.Data[i]);
end;

procedure TForm1.Button3Click(Sender: TObject);
var St : Int64;
i : Byte;
begin
case area2[Teki,Tekj].plm of
2:
begin
if area2[Teki,Tekj].Regime=0 then
begin
  case RadioGroup3.ItemIndex of
   0:  StartBuild(C_Watcher,T_Watcher,101);
   1:  StartBuild(C_Bomber,T_Bomber,102);
   2:  StartBuild(C_Constructor,T_Constructor,103);
  end;
end
else
 begin
   area2[Teki,Tekj].Regime := 0;
 end;
end;
3:  //Выпускаем самолёт на задание.
begin
 i := RadioArray[RadioGroup3.ItemIndex+1];
 if area2[Teki,Tekj].Angar[i]<>nil then
   begin
     PlaneToSky(BankofBases[1].Data[BankofBases[1].FindBase(area2)],area2[Teki,Tekj].Angar[i]);
     Okno := 1;
     Button1Click(Sender);
   end;

end;
end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo1.Visible := not Memo1.Visible;
  if Memo1.Visible  then Button4.Caption := 'Скрыть лог'
                    else Button4.Caption := 'Показать лог';
  if not Memo1.Visible then Button2.Click;
end;

procedure TForm1.Button5Click(Sender: TObject);

begin
 Okno := 0;
 Edit9.Visible := true;
 Edit10.Visible := true;
 Edit11.Visible := true;
 Edit12.Visible := true;
 Edit13.Visible := true;
 Button1.Caption :='Войти в базу';
 CLS;
 Button2Click(Sender);
 Button4.Visible := True;
 Button6.Visible := True;
 ShapeRadius(0);
 ShapesPosition(0);
 ShapesVisible(True);
 RadioGroup1.Visible := False;
 RadioGroup2.Visible := False;
 Teki := TekBi;
 Tekj := TekBj;
 ProgressBar1.Visible := False;
end;

procedure TForm1.CLS; //Oчистка экрана.
var
r:TRect;
begin
 R.Top := 0;
 R.Bottom := ClientHeight;
 R.Left := 0;
 R.Right := ClientWidth;
 Form1.Canvas.FillRect(R);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Form2.ShowModal;
  if F2Otkl = 1 then Close;
end;


procedure TForm1.Edit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//var B:Boolean;
begin
 if Button = mbRight then AddTime(3600*10,True);
 if Button = mbLeft  then AddTime(3600*10,False);
Form1.Button2Click(Form1);
end;

procedure TForm1.Edit2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//var B:Boolean;
begin
 if Button = mbRight then AddTime(3600,True);
 if Button = mbLeft  then AddTime(3600,False);
Form1.Button2Click(Form1);
end;



procedure TForm1.Edit3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//var B:Boolean;
begin
 if Button = mbRight then AddTime(600,True);
 if Button = mbLeft  then AddTime(600,False);
Form1.Button2Click(Form1);
end;



procedure TForm1.Edit4MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//var B:Boolean;
begin
 if Button = mbRight then AddTime(60,True);
 if Button = mbLeft  then AddTime(60,False);
Form1.Button2Click(Form1);
end;


procedure TForm1.Edit7MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
//var B:Boolean;
begin
 if Button = mbRight then AddTime(10,True);
 if Button = mbLeft  then AddTime(10,False);
Form1.Button2Click(Form1);
end;




procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var i,j,k,m:integer;
begin
  for I := 1 to 15 do
   for j := 1 to 15 do
     if area[i,j].areab<>nil then Dispose(area[i,j].areab);
end;



procedure TForm1.FormCreate(Sender: TObject);
var
i,j,k,m,l:integer;
col:Tcolor;
begin
  Okno := 0;
  Randomize;
  Ledits[1] := LabeledEdit1;
  Ledits[2] := LabeledEdit2;
  Ledits[3] := LabeledEdit3;
  Ledits[4] := LabeledEdit4;
  Ledits[5] := LabeledEdit5;
  Ledits[6] := LabeledEdit6;
  Shapes[1] := Shape1;
  Shapes[2] := Shape2;
  Shapes[3] := Shape3;
  Shapes[4] := Shape4;
  for I := 1 to 15 do
   for j := 1 to 15 do
    begin
        area[i,j].clr := $00FF00;
        area[i,j].plm := 0;
        for k := 1 to 4 do area[i,j].Res[k] := Random({Round(10000/k)}C_Maximum[k]);
        area[i,j].areab := Nil;
        for k:=1 to NPlayers do area[i,j].Timerasv[k] :=0;
        area[i,j].Regeneration := True;
   end;
   GenerateTerrain;
  for I := 1 to 15 do
   for j := 1 to 15 do
     if  area[i,j].clr=$FFFF00 then
       for k := 1 to 4 do area[i,j].Res[k] := 0;

  for i:=1 to NPlayers do
   begin
    repeat
    j:=random(15)+1;
    k:=random(15)+1;
    col:= PlanesCols[i];  //random($ffffff);
    until (area[j,k].plm=0) and (area[j,k].clr<>$FFFF00);
    Plems[i] := col;
    NewBase(j,k,i,False);
    if I=1 then   area2 := area[j,k].areaB;   
   end;
    InitBitmaps;
    LoadTerrain;
   TimeStamp := 0;

   //Dengi := 40000;
   //Установка финансов
   for i := 1 to NPlayers do 
     begin
       Banks[i].Reset;
       if i>0 then Banks[i].SetWarPercent(15+Random(10)); //Воинственность, сколько кладём в военный бюджет.  
       Banks[i].AddResource(0,40000); //Каждому по 40 000 кредитов
     end;
   LogMemo := Memo1;
   //Cюда же установить процент военных расходов

   OldStamp := TimeStamp;
   //SolveStamp := TimeStamp;
   MainBmp:=TBitmap.Create;
   MainBmp.Height := 1000;
   MainBmp.Width := 1000;
   for i := 1 to NPlayers do
     begin
       BankofTrigers[i] := TAITriggers.Create(i);
       if i>1 then BankofTrigers[i].AiTurn;
     end;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if key='c' then CheatMode := not CheatMode;

end;


procedure TForm1.ShutDownShape;
begin
  ShapesVisible(False);
  Edit13.Visible := False;
end;

procedure TForm1.OutPutStandart;
begin
  RadioGroup1.Visible := False;
  Edit14.Text := S;
  RadioGroup2.Visible := False;
  ShutDownShape;
end;

procedure TForm1.OutPutMine;
begin
  RadioGroup1.Visible := True;
  RadioGroup1.ItemIndex := area2[Teki,Tekj].Regime;
  RadioGroup1.Items.Strings[0] := 'Добыча со скоростью регенерации';
  RadioGroup1.Items.Strings[1] := 'Добыча с максимальной скоростью';
  Edit14.Text := S;
  RadioGroup2.Visible := False;
  ShutDownShape;
end;

procedure TForm1.StartBuild;
var i:Integer;
begin
  i := BankofBases[1].FindBase(area2);
  BankofTrigers[1].Build(BankofBases[1].Data[i],Cost,Btime,Btype,Teki,Tekj);
  Edit15.Text := IntToStr(Banks[1].CheckRegime(0,5));   
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var Bufi,Bufj:Byte;
  i:SmallInt;
begin
 if (X<1001) and (Y<1001)  then
  begin
    Bufi := Teki;
    Bufj := Tekj;

    case okno  of

    0:
    begin
      if Samv then with TekSam^ do
        begin
           Samv:=False;
           //Здесь прописать висение
           SetFlyEvent(1,PixelsToCoord(X),PixelsToCoord(Y),TekSami);
           if (TekSam.Stype=3) and (area[Event.X,Event.Y].plm=0) and (area[Event.X,Event.Y].Timerasv[1]>=TimeToBase)  then     //ecли основатель и базу можно основать
            begin

              OKRightDlg.ShowModal;
              if OkResult then Bombs:=1   //1 -приказ основать базу.
                          else Bombs:=0;
            end;

          exit;
        end;
      for I := Length(Samolets)-1 downto 0 do
      if Samolets[i]<>nil then
        begin
          if (abs(Samolets[i].CoordX/SectorDlinna*50-X)<10) and ((abs(Samolets[i].CoordY/SectorDlinna*50-Y))<10) and (Samolets[i].plm=1) then
            begin
              Edit9.Text := TypeSamToStr(Samolets[i].Stype);
              Edit10.Text := IntToStr(Samolets[i].Toplivo);
              Edit11.Text := IntToStr(Samolets[i].HitPoints);
              Edit12.Text := IntToStr(Samolets[i].Bombs);
              Samv := True;
              Button1.Caption := 'Отменить полёт';
              TekSam := Samolets[i];
              TekSami := i;
              exit;
            end;
        end;

    Teki:=PixelsToSec(X);
    Tekj:=PixelsToSec(Y);
    Edit13.Text := 'Квадрат '+ XYTOStr(Teki,Tekj); //chr(ord('a')+Tekj) + IntToStr(Teki);
    Image1.Picture := nil;
    case GetType(Teki,Tekj) of
      0: Imagelist1.GetBitmap(1,Image1.Picture.Bitmap);
      9: Imagelist1.GetBitmap(2,Image1.Picture.Bitmap);
      else Imagelist1.GetBitmap(0,Image1.Picture.Bitmap);
    end;
    if area[Teki,Tekj].plm=1 then
      begin

        Edit14.Text := 'Ваша база';
        Edit9.Text := IntToStr(area[Teki,Tekj].Res[1]);
        Edit10.Text :=  IntToStr(area[Teki,Tekj].Res[3]);
        Edit11.Text :=  IntToStr(area[Teki,Tekj].Res[2]);
        Edit12.Text :=  IntToStr(area[Teki,Tekj].Res[4]);
        Button1.Enabled := True;
      end
    else
      begin
        if (area[Teki,Tekj].Timerasv[1]>TimeToBase) or (CheatMode) then
          if area[Teki,Tekj].plm=0 then  Edit14.Text := 'Нет базы'
                                   else  Edit14.Text := 'Вражеская база'
        else Edit14.Text := 'Нет информации';
        if (area[Teki,Tekj].Timerasv[1]>TimeToResources) or (CheatMode)  then
          begin
           Edit9.Text := IntToStr(area[Teki,Tekj].Res[1]);
           Edit10.Text :=  IntToStr(area[Teki,Tekj].Res[3]);
           Edit11.Text :=  IntToStr(area[Teki,Tekj].Res[2]);
           Edit12.Text :=  IntToStr(area[Teki,Tekj].Res[4]);
          end
        else
          begin
        Edit9.Text := 'Неизвестно';
        Edit10.Text :=  'Неизвестно';
        Edit11.Text :=  'Неизвестно';
        Edit12.Text :=  'Неизвестно';
        Button1.Enabled := False;
          end;
       if CheatMode  and (area[Teki,Tekj].plm>0) or  Samv then Button1.Enabled := True
                                                          else Button1.Enabled := False;
      end;
      if Samv then Button1.Caption := 'Отменить полёт'
              else Button1.Caption := 'Войти в базу';
    end;
     1:
       begin
         Teki:=(X-1) div 40 +1;  //Преобразование экранных координат в расположение базы
         Tekj:=(Y-1) div 40 +1;
         case area2[Teki,Tekj].plm of
           0:
             begin
               if (RadioGroup2.Visible= True) and (RadioGroup1.ItemIndex=1) then
                 begin
                   case RadioGroup2.ItemIndex of
                     0: StartBuild(C_AviaFactory,T_AviaFactory,2);
                     1: StartBuild(C_Hangar,T_Hangar,3);
                     2:
                          for i := 1 to 4 do
                            if Shapes[i].Height>SmallRadius then StartBuild(C_Mine,T_Mine,i+3);
                   end;
                   Teki := Bufi;
                   Tekj := Bufj;
                   Button2.Click;
                 end
               else
                 begin
                   RadioGroup1.Visible := False;
                   RadioGroup2.Visible := False;
                   Edit14.Text := '';
                 end;

             end;
           1:
             begin
               RadioGroup1.Visible := True;
               RadioGroup1.ItemIndex := 0;
               RadioGroup1.Items.Strings[0] := 'Модернизация';
               RadioGroup1.Items.Strings[1] := 'Строительство';
               Edit14.Text := 'Штаб';
               RadioGroup2.Visible := True;
               RadioGroup2.ItemIndex := area2[Teki,Tekj].Regime;
               ShutDownShape;
               ProgressBar1.BarColor := clGreen;  //clBlue;
               ProgressBar1.Position := Round(100*area2[Teki,Tekj].HitPoints/H_Main);
               if ProgressBar1.Position<67  then   ProgressBar1.BarColor := clYellow;
               if ProgressBar1.Position<34  then   ProgressBar1.BarColor := clRed;
             end;
           2: OutPutStandart(S_AviaFactory);
           3: OutPutStandart(S_Hangar);
           4: OutPutMine(S_BMine);
           5: OutPutMine(S_GMine);
           6: OutPutMine(S_RMine);
           7: OutPutMine(S_VMine);
           130: OutPutBuilding(S_AviaFactory);
           131: OutPutBuilding(S_Hangar);
           132: OutPutBuilding(S_BMine);
           133: OutPutBuilding(S_GMine);
           134: OutPutBuilding(S_RMine);
           135: OutPutBuilding(S_VMine);
         end;
       end;
    end;
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  if area2[Teki,Tekj].plm=1 then RadioGroup2Click(Sender);
end;

procedure TForm1.RadioGroup2Click(Sender: TObject);
begin
   if (RadioGroup2.ItemIndex=2) and (RadioGroup1.ItemIndex=1) then ShapesVisible(True)
                                                              else ShapesVisible(False);

end;

procedure TForm1.ShapesVisible;
var i:Integer;
begin
  for i:=Low(Shapes) to High(Shapes) do Shapes[i].Visible := B;
end;

procedure TForm1.LeditsVisible;
var i:Integer;
begin
  for I := Low(Ledits) to High(Ledits) do  Ledits[i].Visible := B;
end;

procedure TForm1.RadioGroup3Click(Sender: TObject);
var i:Integer;
begin
  case area2[Teki,Tekj].plm of
  2:
   case RadioGroup3.ItemIndex of
    0:
     begin
      Lev.Text := TimeToBuild(T_Watcher);
      OutPutCost(C_Watcher);  
     end;
    1:
     begin
       Lev.Text := TimeToBuild(T_Bomber);  //'1 д. 1 ч.';
       OutPutCost(C_Bomber);
     end;
    2:
     begin
       Lev.Text := TimeToBuild(T_Constructor);//'1 д. 4 ч.';
       OutPutCost(C_Constructor);
     end;
   end;
    3:
      begin
        i := RadioArray[RadioGroup3.ItemIndex+1];
        if area2[Teki,Tekj].Angar[i]<>nil then
          begin
            Lev.Text := TypeSamToStr(area2[Teki,Tekj].Angar[i].Stype);
            LabeledEdit1.Text := IntToStr(area2[Teki,Tekj].Angar[i].HitPoints);
            LabeledEdit2.Text := IntToStr(area2[Teki,Tekj].Angar[i].Toplivo);
          end;
      end;
  end;
//Lev.Repaint;
end;

procedure TForm1.ShapeRadius;
var i:Integer;
begin
  for i:=1 to 4 do
    begin
       Shapes[i].Height := SmallRadius;
       Shapes[i].Width  := SmallRadius;
    end;
  if N>0 then
    begin
     Shapes[N].Height := BigRadius;
     Shapes[N].Width  := BigRadius;
    end;
end;


procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Okno=1 then ShapeRadius(1);
end;

procedure TForm1.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if Okno=1 then ShapeRadius(2);
end;

procedure TForm1.Shape3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Okno=1 then ShapeRadius(3);
end;

procedure TForm1.Shape4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Okno=1 then ShapeRadius(4);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
A:TTimeRecord;
begin
  AddTime(1,True);//Inc(TimeStamp);
  A:= Int64ToTIme(TimeStamp);  //Обязательно прибавляем время.
  //TimeGO?
  Edit1.Text := IntToStr(A.Hours div 10);
  Edit2.Text := IntToStr(A.Hours mod 10);
  Edit3.Text := IntToStr(A.Minutes div 10);
  Edit4.Text := IntToStr(A.Minutes mod 10);
  Edit7.Text := IntToStr(A.Seconds div 10);
  Edit8.Text := IntToStr(A.Seconds mod 10);
  Label1.Caption := 'День ' + IntToStr(A.Days);
end;

end.
