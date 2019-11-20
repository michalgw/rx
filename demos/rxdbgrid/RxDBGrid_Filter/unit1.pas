unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, rxdbgrid, rxmemds, Forms, Controls, Graphics, DBGrids,
  Dialogs, StdCtrls, ExtCtrls, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    dsData: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    rxDataID_R: TLongintField;
    rxDataMEMO: TMemoField;
    RxDBGrid1: TRxDBGrid;
    rxData: TRxMemoryData;
    rxDataCODE: TLongintField;
    rxDataID: TLongintField;
    rxDataNAME: TStringField;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rxDataAfterInsert(DataSet: TDataSet);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  rxData.Open;
  for i:=1 to 20 do
  begin
    rxData.AppendRecord([i, i mod 4, Format('Line %d', [i]), i, 'Строка МЕМО ' + IntToStr(i div 2)]);
    if i mod 5 = 0 then
      rxData.AppendRecord([null, null, 'Пустая строка']);
  end;
  rxData.First;

  Label1.Caption:='';
  Label2.Caption:='';
  Label3.Caption:='';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Label1.Caption:=RxDBGrid1.ColumnByFieldName('CODE').Filter.CurrentValues.Text;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Label2.Caption:=RxDBGrid1.ColumnByFieldName('NAME').Filter.CurrentValues.Text;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Label3.Caption:=RxDBGrid1.ColumnByFieldName('ID_R').Filter.CurrentValues.Text;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
    RxDBGrid1.Options:=RxDBGrid1.Options + [dgDisplayMemoText]
  else
    RxDBGrid1.Options:=RxDBGrid1.Options - [dgDisplayMemoText];
end;

procedure TForm1.rxDataAfterInsert(DataSet: TDataSet);
begin
  rxDataID_R.AsInteger:=rxData.RecordCount + 1;
end;

end.

