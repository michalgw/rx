{ rxdbgrid_findunit unit

  Copyright (C) 2005-2021 Lagunov Aleksey alexs75@yandex.ru and Lazarus team
  original conception from rx library for Delphi (c)

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit rxdbgrid_findunit;

{$I rx.inc}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls, rxdbgrid, DB, LCLType;

type

  { TrxDBGridFindForm }

  TrxDBGridFindForm = class(TForm)
    BtnFind: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioGroup1: TRadioGroup;
    procedure BtnFindClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioGroup1SelectionChanged(Sender: TObject);
  private
    FFirstSearch: Boolean;
    FGrid:TRxDBGrid;
    FDataSet:TDataSet;
    procedure SetGrid(AGrid:TRxDBGrid);
  public
    { public declarations }
  end; 

procedure ShowRxDBGridFindForm(Grid:TRxDBGrid);

implementation
uses rxdbutils, DBGrids, rxdconst, Variants;

{$R *.lfm}

procedure ShowRxDBGridFindForm(Grid: TRxDBGrid);
var
  rxDBGridFindForm: TrxDBGridFindForm;
begin
  rxDBGridFindForm:=TrxDBGridFindForm.Create(Application);
  rxDBGridFindForm.SetGrid(Grid);
  rxDBGridFindForm.ShowModal;
  rxDBGridFindForm.Free;
end;

{ TrxDBGridFindForm }

procedure TrxDBGridFindForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TrxDBGridFindForm.Edit1Change(Sender: TObject);
begin
  if RadioGroup1.ItemIndex = 0 then
    FFirstSearch:=true;
end;

procedure TrxDBGridFindForm.FormCreate(Sender: TObject);
begin
  Caption:=sRxDbGridFindCaption;
  Label1.Caption:=sRxDbGridFindText;
  RadioButton1.Caption:=sRxDbGridFindOnField;
  RadioButton2.Caption:=sRxDbGridFindInAllFileds;
  CheckBox1.Caption:=sRxDbGridFindCaseSens;
  CheckBox2.Caption:=sRxDbGridFindPartial;
  RadioGroup1.Caption:=sRxDbGridFindDirecion;
  RadioGroup1.Items.Clear;
  RadioGroup1.Items.Add(sRxDbGridFindRangeAll);
  RadioGroup1.Items.Add(sRxDbGridFindRangeForw);
  RadioGroup1.Items.Add(sRxDbGridFindRangeBack);
  BtnFind.Caption:=sRxFindMore;
  Button2.Caption:=GetButtonCaption(idButtonCancel);

  RadioGroup1.ItemIndex:=0;
end;

procedure TrxDBGridFindForm.FormShow(Sender: TObject);
begin
  Edit1.SetFocus;
end;

procedure TrxDBGridFindForm.RadioButton1Click(Sender: TObject);
begin
  ComboBox1.Enabled:=RadioButton1.Checked;
end;

procedure TrxDBGridFindForm.RadioGroup1SelectionChanged(Sender: TObject);
begin
  if RadioGroup1.ItemIndex = 0 then
     FFirstSearch:=True;
end;

procedure TrxDBGridFindForm.BtnFindClick(Sender: TObject);
var
  FieldName, S:string;
  LOptions: TLocateOptions;
  SearchOrigin:TRxSearchDirection;
  P:TBookMark;
  R:boolean;
  FC: TRxColumn;
  RF:TField;
  i: Integer;
begin
  { TODO -oalexs : Необходимо переделать поиск по колонке - искать всегда по строковому представлению. Иначе не ищет по дате-времени }
  if (Edit1.Text<>'') and (ComboBox1.ItemIndex>=0) and (ComboBox1.ItemIndex<ComboBox1.Items.Count) and (ComboBox1.Text<>'') then
  begin
    try
      FC:=FGrid.ColumnByCaption(ComboBox1.Text);
      if not Assigned(FC) then Exit;
      FieldName:=FC.FieldName;
      LOptions:=[];
      if not CheckBox1.Checked then
        LOptions:=LOptions+[loCaseInsensitive];

      if CheckBox2.Checked then
        LOptions:=LOptions+[loPartialKey];

      SearchOrigin:=TRxSearchDirection(RadioGroup1.ItemIndex);
      {$IFDEF NoAutomatedBookmark}
      P:=FDataSet.GetBookmark;
      {$ELSE}
      P:=FDataSet.Bookmark;
      {$ENDIF}
      if SearchOrigin = rsdAll Then
      begin
        if FFirstSearch then
          FDataSet.First
        else
          FDataSet.Next;
        SearchOrigin:=rsdForward;
      end
      else
      if SearchOrigin = rsdForward then
        FDataSet.Next
      else
      if SearchOrigin = rsdBackward then
        FDataSet.Prior;
      if RadioButton1.Checked then
        R:=DataSetLocateThrough(FDataSet, FieldName, Edit1.Text, LOptions, SearchOrigin)
      else
      begin
        S:='';
        for i:=0 to FDataSet.Fields.Count-1 do
        begin
          if S<>'' then S:=S + ';';
          S:=S + FDataSet.Fields[i].FieldName;
        end;
        R:=DataSetLocateThroughEx(FDataSet, S, Edit1.Text, LOptions, SearchOrigin, false, RF);
        if R then
          FGrid.SelectedField:=RF;
      end;
    finally
      {$IFDEF NoAutomatedBookmark}
      if not R then
        FDataSet.GotoBookmark(P);
      FDataSet.FreeBookmark(P);
      {$ELSE}
      if not R then
        FDataSet.Bookmark:=P;
      {$ENDIF}
      FFirstSearch := False;
    end;
  end;
end;

procedure TrxDBGridFindForm.SetGrid(AGrid: TRxDBGrid);
var
  i:integer;
begin
  if AGrid=FGrid then exit;
  FGrid:=AGrid;
  ComboBox1.Items.Clear;
  if Assigned(AGrid) then
  begin
    for i:=0 to AGrid.Columns.Count-1 do
    begin
      if not (coDisableDialogFind in AGrid.Columns[i].Options) then
        ComboBox1.Items.Add(AGrid.Columns[i].Title.Caption);
    end;

    ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(AGrid.SelectedColumn.Title.Caption);
    CheckBox1.Checked := not (loCaseInsensitive in AGrid.SearchOptions.QuickSearchOptions);
    CheckBox2.Checked := loPartialKey in AGrid.SearchOptions.QuickSearchOptions;
  end;

  FDataSet:=nil;
  if Assigned(FGrid) and Assigned(FGrid.DataSource) then
    FDataSet:=FGrid.DataSource.DataSet;
  BtnFind.Enabled:=Assigned(FDataSet) and FDataSet.Active
end;

end.

