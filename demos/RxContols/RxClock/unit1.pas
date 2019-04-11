unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  rxclock;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    RxClock1: TRxClock;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RxClock1Alarm(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.RxClock1Alarm(Sender: TObject);
begin
  ShowMessage('Alarm!');
  CheckBox1.Checked:=false;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  RxClock1.AlarmEnabled:=CheckBox1.Checked;

  if CheckBox1.Checked then
  begin
    RxClock1.AlarmHour:=SpinEdit1.Value;
    RxClock1.AlarmMinute:=SpinEdit2.Value;
    RxClock1.AlarmSecond:=SpinEdit3.Value;
  end;

  SpinEdit1.Enabled:=not CheckBox1.Checked;
  SpinEdit2.Enabled:=SpinEdit1.Enabled;
  SpinEdit3.Enabled:=SpinEdit1.Enabled;

  Label2.Enabled:=SpinEdit1.Enabled;
  Label3.Enabled:=SpinEdit1.Enabled;
  Label4.Enabled:=SpinEdit1.Enabled;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  H, M, S, MS: word;
begin
  DecodeTime(Now, H, M, S, MS);
  SpinEdit1.Value:=H;
  SpinEdit2.Value:=M;
end;

end.

