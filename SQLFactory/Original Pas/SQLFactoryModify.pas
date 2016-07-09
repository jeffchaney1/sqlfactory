{******************************************************************************
  Implementation of SQLFactory classes that cause a modification of the data.

  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2014/09/17 11:15:32 $
  @group Shared.SQLFactory
  @version $Id: SQLFactoryModify.pas,v 1.21 2014/09/17 11:15:32 jchaney Exp $
  @version
******************************************************************************}
                          
unit SQLFactoryModify;

interface

uses UnitVersion, Classes, StringBuffer, TypedList, SysUtils, ADODB, PRADODB,
  SQLFactoryBase, SQLFactorySelect, CommonStringLib;

{$TYPEINFO ON}
type
  {******************************************************************************
    Base class of SQL Factory classes that modify data.
    @decendant TSQLInsertFactory
    @decendant TSQLDeleteFactory
    @decendant TSQLUpdateFactory
    @see SQLFactory
  ******************************************************************************}
  TSQLModifyBase = class(TSQLElementParent)
  private
    fModifyTable : TTable;
    fColumns : TFieldValueList;

  protected
    {******************************************************************************
      Getter for ModifyTable property
      @group Getters
    ******************************************************************************}
    function GetModifyTable : TTable;
    {******************************************************************************
      Setter for ModifyTable property
      @group Setters
    ******************************************************************************}
    procedure SetModifyTable(Value : TTable);
    {******************************************************************************
      Getter for Columns property
      @group Getters
    ******************************************************************************}
    function GetColumns : TFieldValueList;

    procedure InternalBuildModifyTable(sql : TWideStringBuffer;
                      parameters : TParameterList; const Indent : WideString);

    {******************************************************************************
      The list of columns that are to be modified.
      &nbsp;
      Each column can be assigned a Parameter value or a literal value.
      @see TFieldValueList
      @see TFieldValue
    ******************************************************************************}
    property Columns : TFieldValueList read GetColumns;
  public
    {******************************************************************************
      Constructor
      @param AOwner The SQL Factory class that is instantiating this object.
        Usually for the top level parent SQLFactory objects this will be nil.
      @group Constructors
    ******************************************************************************}
    constructor Create(AOwner : TPersistent); 
//    constructor Create(modifyTable : WideString); overload;
//    constructor Create(tableSchema, modifyTable : WideString); overload;
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      Execute the SQL Command stored in this factory.
      &nbsp;
      Builds the SQL Command stored in the Factory, creates a TPRADOCommand and
      fills in the TPRADOCommand properties with the values from the Factory.
      @param Connection The TPRADOConnection this command should be run on.
      @param ExecuteOptions (Optional: []) The set of TExecuteOptions to control
        the execution of the SQL Command.
      @param Execute (Optional: False) Determins if the TPRADOCommand should have
        already been executed when this function returns.
      @return The TPRADOCommand filled in with the values from this SQL Factory.
    ******************************************************************************}
    function prepareCommand(Connection : TPRADOConnection; ExecuteOptions : TExecuteOptions = []; Execute : Boolean = False) : TPRADOCommand;
    {******************************************************************************
      Execute the SQL Command stored in this factory.
      &nbsp;
      Builds the SQL Command stored in the Factory and executes it on the
      Connection.
      @param Connection The TPRADOConnection this command should be run on.
      @param ExecuteOptions (Optional: []) The set of TExecuteOptions to control
        the execution of the SQL Command.
      @return An integer indicating how many rows were affected by the command.
    ******************************************************************************}
    function ExecuteCommand(Connection : TPRADOConnection; ExecuteOptions : TExecuteOptions = []) : Integer;
  end;

  {******************************************************************************
    SQL Insert Command Factory
    &nbsp;
    Provides an easy way for a program to create a SQL Insert command
  ******************************************************************************}
  TSQLInsertFactory = class(TSQLModifyBase)
  private
    fFromQuery : TSQLSelectFactory;

  protected
    procedure InternalBuildColumnList(sql: TWideStringBuffer;
      parameters: TParameterList; const indent: WideString); virtual;
    procedure InternalBuildValuesList(sql: TWideStringBuffer;
      parameters: TParameterList; const indent: WideString); virtual;
    {******************************************************************************
      Getter for FromQuery property
      @group Getters
    ******************************************************************************}
    function GetFromQuery : TSQLSelectFactory; virtual;
    {******************************************************************************
      Setter for FromQuery property
      @group Setters
    ******************************************************************************}
    procedure setFromQuery(subSelect : TSQLSelectFactory);
  public
    constructor Create(AOwner : TPersistent=nil);

    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

    {******************************************************************************
      SQL INSERT implementation of the abstract function introduced in ISQLElement
      &nbsp;
      Actualy builds the SQL statement from the values in the factory.
      @see SQLFactoryBase.ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;
    
    {******************************************************************************
      List of columns to be inserted into the table.
      &nbsp;
      If no columns are defined
      @see TSQLModifyFactory.Columns
      @see TFieldValueList
      @see TFieldValue
    ******************************************************************************}
    property Columns;

    {******************************************************************************
      A Source SQL SELECT command
      &nbsp;
      A SQL SELECT statement that is to be used as a source for the
      rows being inserted into the table.
    ******************************************************************************}
    property fromQuery : TSQLSelectFactory read GetfromQuery;

    {******************************************************************************
      The table that is to have rows inserted into it.
    ******************************************************************************}
    property intoTable : TTable read GetModifyTable write SetModifyTable;
  end;

  TCustomSQLConditionalModifyFactory = class(TSQLModifyBase)
  private
    fWhereClauses : TConditionList;
    fAllowNoConditions : Boolean;

  protected
    procedure InternalBuildWhereClause(sql: TWideStringBuffer;
        parameters: TParameterList; const indent: WideString); virtual;

    {******************************************************************************
      SQL DELETE implementation of the abstract function introduced in ISQLElement
      &nbsp;
      Actualy builds the SQL statement from the values in the factory.
      @see SQLFactoryBase.ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;
    {******************************************************************************
      Getter for WhereClauses property
      @group Getters
    ******************************************************************************}
    function GetWhereClauses : TConditionList; virtual;

    {******************************************************************************
      Allows a DELETE command to be built without any conditions.
      &nbsp;
      This property defaults to False.  It will throw an exception of buildSQL()
      is called but there are no conditions defined in the factory.  This is
      designed to stop an accidental deletion of all records.
    ******************************************************************************}
    property AllowNoConditions : Boolean read fAllowNoConditions write fAllowNoConditions;

    {******************************************************************************
      The conditions to select the records to be deleted.
    ******************************************************************************}
    property Where : TConditionList read GetWhereClauses;
  public
    {******************************************************************************
      Destructor
      @group Constructors
    ******************************************************************************}
    destructor Destroy; override;

  end;

  {******************************************************************************
    SQL Delete Factory
    &nbsp;
    Provides an easy way for a program to create a SQL DELETE command
  ******************************************************************************}
  TSQLDeleteFactory = class(TCustomSQLConditionalModifyFactory)
  public
    constructor Create(AOwner : TPersistent=nil);
    {******************************************************************************
      The table to have records deleted.
    ******************************************************************************}
    property UpdateTable : TTable read GetModifyTable write SetModifyTable;

   {******************************************************************************
      Allows a DELETE command to be built without any conditions.
      &nbsp;
      This property defaults to False.  It will throw an exception of buildSQL()
      is called but there are no conditions defined in the factory.  This is
      designed to stop an accidental deletion of all records.
    ******************************************************************************}
    property AllowNoConditions;

    {******************************************************************************
      The conditions to select the records to be deleted.
    ******************************************************************************}
    property Where;

    procedure buildSQL(sql: TWideStringBuffer;
            parameters: TParameterList; const indent: WideString); override;
  end;

  {******************************************************************************
    SQL Update Factory
    &nbsp;
    Provides an easy way for a program to create a SQL UPDATE command
  ******************************************************************************}
  TCustomSQLUpdateFactory = class(TCustomSQLConditionalModifyFactory)
  protected
    function InternalIncludeColumn(Column : TFieldValueDef) : Boolean; virtual;

    procedure InternalBuildUpateColumns(sql: TWideStringBuffer;
          parameters: TParameterList; const indent: WideString); virtual;

    {******************************************************************************
      SQL UPDATE implementation of the abstract function introduced in ISQLElement
      &nbsp;
      Actualy builds the SQL statement from the values in the factory.
      @see SQLFactoryBase.ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

  end;

  TSQLUpdateFactory = class(TCustomSQLUpdateFactory)
  public
    constructor Create(AOwner : TPersistent=nil);
    {******************************************************************************
      SQL UPDATE implementation of the abstract function introduced in ISQLElement
      &nbsp;
      Actualy builds the SQL statement from the values in the factory.
      @see SQLFactoryBase.ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

    {******************************************************************************
      The table to have records updated
    ******************************************************************************}
    property UpdateTable : TTable read GetModifyTable write SetModifyTable;

    {******************************************************************************
      Allows a UPDATE command to be built without any conditions.
      &nbsp;
      This property defaults to False.  It will throw an exception of buildSQL()
      is called but there are no conditions defined in the factory.  This is
      designed to stop an accidental deletion of all records.
    ******************************************************************************}
    property AllowNoConditions;

    {******************************************************************************
      The columns to be updated
      @see TSQLModifyFactory.Columns
      @see TFieldValueList
      @see TFieldValue
    ******************************************************************************}
    property Columns;


    {******************************************************************************
      The conditions to select the records to be updated
    ******************************************************************************}
    property Where;
  end;

  TSQLInsertOrUpdateFactory = class(TCustomSQLUpdateFactory)
  private
    fKeyColumns : TWideStringList;
    fUpdateOnlyIfDifferent : Boolean;
    fInsertOnly : Boolean;
  protected
    function Get_KeyColumns : TWideStringList;
    function Get_UpdateOnlyIfDifferent : Boolean;
    procedure Set_UpdateOnlyIfDifferent(Value : Boolean);
    function Get_InsertOnly: Boolean;
    procedure Set_InsertOnly(const Value: Boolean);

    function InternalIncludeColumn(Column: TFieldValueDef): Boolean; override;

    procedure InternalBuildWhereClause(sql: TWideStringBuffer;
                  parameters: TParameterList; const indent: WideString); override;
  public
    constructor Create(AOwner : TPersistent=nil);
    destructor Destroy; override;

    {******************************************************************************
      SQL INSERT and UPDATE implementation of the abstract function introduced in ISQLElement
      &nbsp;
      Actualy builds the SQL statement from the values in the factory.
      IF NOT EXISTS (SELECT TOP 1 * FROM (Table) WHERE {keys match))
        UPDATE (non-Key Field) WHERE (keys match) AND (one or more non-keys do not match)
      ELSE
        INSERT (All Fields with values defined in columns)
      @see SQLFactoryBase.ISQLElement
    ******************************************************************************}
    procedure buildSQL(sql : TWideStringBuffer; parameters : TParameterList; const indent : WideString = ''); override;

    {******************************************************************************
      The table to have records inserted or updated
    ******************************************************************************}
    property UpdateTable : TTable read GetModifyTable write SetModifyTable;

    {******************************************************************************
      The columns to be updated
      @see TSQLModifyFactory.Columns
      @see TFieldValueList
      @see TFieldValue
    ******************************************************************************}
    property Columns;

    property KeyColumns : TWideStringList read Get_KeyColumns;
    procedure AddKeyColumns(ColumnNames : array of WideString);

    //property DiffColumns : TFieldValueList read Get_DiffColumns;
    property UpdateOnlyIfDifferent : Boolean read Get_UpdateOnlyIfDifferent write Set_UpdateOnlyIfDifferent default True;
    property InsertOnly : Boolean read Get_InsertOnly write Set_InsertOnly default False;
    property IntoTable : TTable read GetModifyTable;  // same as UpdateTable
  end;



implementation

uses Math,  CommonObjLib, Variants, DB;

{ TSQLModifyBase }
constructor TSQLModifyBase.Create(AOwner : TPersistent);
begin
  inherited Create(AOwner);
end;

//constructor TSQLModifyBase.Create(modifyTable : WideString);
//begin
//  Create('', modifyTable);
//end;
//
//constructor TSQLModifyBase.Create(tableSchema, modifyTable : WideString);
//begin
//  inherited Create;
//  setModifyTable(tableSchema, modifyTable);
//end;
//
destructor TSQLModifyBase.Destroy;
begin
  SafeFreeAndNil(fColumns);
  SafeFreeAndNil(fModifyTable);
  inherited;
end;

function TSQLModifyBase.GetModifyTable: TTable;
begin
  if (fModifyTable = nil) then begin
    fModifyTable := TTable.Create(Nil);
  end;

  Result := fModifyTable;
end;

procedure TSQLModifyBase.SetModifyTable(Value : TTable);
begin
  if (fModifyTable <> Value) then begin
    if (FModifyTable <> nil) then
      SafeFree(FModifyTable);

    fModifyTable := Value;
  end;
end;


function TSQLModifyBase.GetColumns: TFieldValueList;
begin
  if (fColumns = nil) then
    fColumns := TFieldValueList.Create(Self);

  Result := fColumns;
end;

procedure TSQLModifyBase.InternalBuildModifyTable(sql : TWideStringBuffer; parameters : TParameterList; const Indent : WideString);
begin
  if (not IsEmpty(GetModifyTable.TableSchema)) then begin
    sql.Append(EnforceBrackets('[', GetModifyTable.TableSchema, ']'));
    sql.append('.');
  end;

  sql.append(EnforceBrackets('[', GetModifyTable.tableName, ']'));
end;

function TSQLModifyBase.prepareCommand( Connection: TPRADOConnection; ExecuteOptions : TExecuteOptions = []; Execute : Boolean = False): TPRADOCommand;
Var
  Parameters : TParameterList;
  RecordsAffected : Integer;
begin
  Result := TPRADOCommand.Create(nil);
  Parameters := TParameterList.Create(Self);
  try try
    Result.Connection := Connection;
    Result.CommandText := buildSQL(Parameters);
    Result.CommandType := cmdText;
    Result.ExecuteOptions := ExecuteOptions;
    // I'm pretty sure setting the parameters on the Command Object has no affect
    //   But I'm leaving this in for when the TPRADOCommand object works as expected.
    //if (Parameters.Count > 0) then
    //  Parameters.CopyTo(Result.Parameters);
    Parameters.Clear;

    if (Execute) then begin
      RecordsAffected := 0;
      Result.Execute(RecordsAffected, Parameters.asVariantArray);
    end;
  except
    SafeFree(Result);
    Result := nil;
    raise;
  end;
  finally
    SafeFree(Parameters);
  end;
end;


function TSQLModifyBase.ExecuteCommand(Connection: TPRADOConnection; ExecuteOptions: TExecuteOptions): Integer;
Var
  Parameters : TParameterList;
  Command : TPRADOQuery;
begin
  Command := TPRADOQuery.Create(nil);
  Parameters := TParameterList.Create(Self);
  try
    Command.Connection := Connection;
    Command.SQL.Text := buildSQL(Parameters);
    Command.ExecuteOptions := ExecuteOptions;

    if (Parameters.Count > 0) then
      Parameters.CopyTo(Command.Parameters);
    Result := Command.ExecSQL;
  finally
    SafeFree(Command);
    SafeFree(Parameters);
  end;
end;

{ TSQLInsertFactory }
constructor TSQLInsertFactory.Create(AOwner : TPersistent=nil);
begin
  inherited Create(AOwner);
end;

destructor TSQLInsertFactory.Destroy;
begin
  SafeFree(fFromQuery);
  inherited;
end;

function TSQLInsertFactory.GetFromQuery: TSQLSelectFactory;
begin
  if (fFromQuery = nil) then
    fFromQuery := TSQLSelectFactory.Create(Self);

  Result := fFromQuery;
end;

procedure TSQLInsertFactory.setFromQuery(subSelect: TSQLSelectFactory);
begin
  if (fFromQuery <> nil) then
    SafeFree(fFromQuery);

  fFromQuery := subSelect;
end;

procedure TSQLInsertFactory.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  sql.append(indent);
  sql.append('INSERT INTO ');

  self.InternalBuildModifyTable(sql, parameters, indent);

  sql.append(#13#10);

  self.InternalBuildColumnList(sql, parameters, indent);

  sql.append(#13#10);

  InternalBuildValuesList(sql, parameters, indent);
end;

procedure TSQLInsertFactory.InternalBuildColumnList(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  if (Columns.Count > 0) then begin
    sql.append('(');
    Columns.buildSQL(sql, parameters, indent);
    sql.append(') ');
  end;
end;

procedure TSQLInsertFactory.InternalBuildValuesList(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  if not Columns.BuildValuesList(sql, parameters, indent) then begin
    if (fromQuery.fromTable.TableName <> '') then begin
      fromQuery.buildSQL(sql, parameters, indent);
    end
    else
      raise ESQLFactoryException.Create('No source for values to be inserted has been defined');
  end;
end;

{ TCustomSQLConditionalModifyFactory }
destructor TCustomSQLConditionalModifyFactory.Destroy;
begin
  SafeFree(fWhereClauses);
  inherited;
end;

function TCustomSQLConditionalModifyFactory.GetWhereClauses: TConditionList;
begin
  if (fWhereClauses = nil) then
    fWhereClauses := TConditionList.Create(Self);

  Result := fWhereClauses;
end;

procedure TCustomSQLConditionalModifyFactory.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  if (not AllowNoConditions) and (Where.Count = 0) then
    raise ESQLUpdateNoConditions.Create('No conditions on which records are to be deleted have been defined.');

  InternalBuildModifyTable(sql, parameters, indent);

  InternalBuildWhereClause(sql, parameters, indent);
end;

procedure TCustomSQLConditionalModifyFactory.InternalBuildWhereClause(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  if (where.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);
    sql.append(' WHERE ');
    where.buildSQL(sql, parameters, indent);
  end;
end;

{ TSQLDeleteFactory }
constructor TSQLDeleteFactory.Create(AOwner : TPersistent=nil);
begin
  inherited Create(AOwner);
end;

procedure TSQLDeleteFactory.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  sql.append('DELETE ');

  inherited;
end;

{ TCustomSQLUpdateFactory }

procedure TCustomSQLUpdateFactory.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  if (not AllowNoConditions) and (Where.Count = 0) then
    raise ESQLUpdateNoConditions.Create('No conditions on which records are to be updated have been defined.');
  if (Columns.Count = 0) then
    raise ESQLUpdateNoColumns.Create('No columns have been defined for updating.');

  sql.append('UPDATE ');

  InternalBuildModifyTable(sql, parameters, indent);

  InternalBuildUpateColumns(sql, parameters, indent);

  InternalBuildWhereClause(sql, parameters, indent);

end;


function TCustomSQLUpdateFactory.InternalIncludeColumn(Column : TFieldValueDef) : Boolean;
begin
  Result := True;
end;

procedure TCustomSQLUpdateFactory.InternalBuildUpateColumns(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
Var
  i : Integer;
  First : Boolean;
begin
  if (Columns.Count > 0) then begin
    sql.append(#13#10);
    sql.append(indent);

    sql.append('SET ');
    First := True;
    for i := 0 to Columns.Count - 1 do begin
      if InternalIncludeColumn(Columns[i]) then begin
        if (not First) then
          sql.append(',');
        sql.append(#13#10);
        sql.append(indent);
        sql.append('    ');

        Columns[i].buildSQL(sql, nil, '');
        sql.append(' = ');
        Columns[i].buildValue(sql, parameters);
        First := False;
      end;
    end;
  end;
end;

{ TSQLUpdateFactory }
constructor TSQLUpdateFactory.Create(AOwner : TPersistent=nil);
begin
  inherited Create(AOwner);
end;

procedure TSQLUpdateFactory.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
begin
  inherited;
end;

{ TSQLInsertOrUpdate }
constructor TSQLInsertOrUpdateFactory.Create(AOwner : TPersistent=nil);
begin
  inherited Create(AOwner);

  fUpdateOnlyIfDifferent := True;
  fInsertOnly := False;
end;

destructor TSQLInsertOrUpdateFactory.Destroy;
begin
  SafeFree(fKeyColumns);
  //SafeFree(fDiffColumns);
  inherited;
end;

function TSQLInsertOrUpdateFactory.Get_KeyColumns : TWideStringList;
begin
  if (fKeyColumns = nil) then begin
    fKeyColumns := TWideStringList.Create;//(Self);
    fKeyColumns.Duplicates := dupIgnore;
  end;
  Result := fKeyColumns;
end;

procedure TSQLInsertOrUpdateFactory.AddKeyColumns(ColumnNames : array of WideString);
Var
  i : Integer;
begin
  for i := 0 to Length(ColumnNames)-1 do
    KeyColumns.Add(ColumnNames[i]);
end;

function TSQLInsertOrUpdateFactory.Get_UpdateOnlyIfDifferent : Boolean;
begin
  Result := fUpdateOnlyIfDifferent;
end;

procedure TSQLInsertOrUpdateFactory.Set_UpdateOnlyIfDifferent(Value : Boolean);
begin
  fUpdateOnlyIfDifferent := Value;
end;

function TSQLInsertOrUpdateFactory.Get_InsertOnly: Boolean;
begin
  Result := fInsertOnly;
end;

procedure TSQLInsertOrUpdateFactory.Set_InsertOnly(const Value: Boolean);
begin
  fInsertOnly := Value;
end;

function TSQLInsertOrUpdateFactory.InternalIncludeColumn(Column : TFieldValueDef) : Boolean;
begin
  Result := KeyColumns.IndexOf(Column.ColumnName) = -1;
end;

procedure TSQLInsertOrUpdateFactory.InternalBuildWhereClause(sql: TWideStringBuffer;
              parameters: TParameterList; const indent: WideString);
Var
  i : Integer;
  FirstCondition, FirstOR : Boolean;
  Column : TFieldValueDef;
begin
  FirstCondition := True;
  for i := 0 to KeyColumns.Count - 1 do begin
    Column := Columns[KeyColumns[i]];
    if (Column = nil) then
      Raise Exception.create('Key Column, "' + KeyColumns[i] + '" was not found in Columns.');

    sql.append(#13#10);
    sql.append(indent);
    if (FirstCondition) then
      sql.append('WHERE ')
    else
      sql.append(' AND ');
    sql.append('([');
    sql.append(Column.ColumnName);
    sql.append('] = ');
    Column.BuildValue(Sql, parameters);
    sql.append(')');

    FirstCondition := False;
  end;

  // Only update only if one OR more of the Non-Key Values are different
  If Self.UpdateOnlyIfDifferent then begin
    FirstOR := True;
    for i := 0 to Columns.Count - 1 do begin
      Column := Columns[i];
      if (KeyColumns.IndexOf(Column.ColumnName) = -1) then begin
        if (FirstOR) then begin
          if (FirstCondition) then begin
            sql.append(#13#10);
            sql.append(indent);
            sql.append('WHERE (');
          end
          else
            sql.append(' AND (');
          end
        else begin
          sql.append(indent);
          sql.append(' OR ');
        end;
        
        sql.append('([');
        sql.append(Column.ColumnName);
        sql.append('] <> ');
        Column.BuildValue(Sql, parameters);
        sql.append(')');
        FirstCondition := False;
        FirstOR := False;
      end;
    end;

    if (not FirstOR) then
      sql.append(')');

  end;

//  // Add any additional conditions that may have been added to the update.
//  if (Where.Count > 0) then begin
//    if (FirstCondition) then begin
//      sql.append(#13#10);
//      sql.append(indent);
//      sql.append('WHERE ');
//    end
//    else
//      sql.append(' AND ');
//    where.buildSQL(sql, parameters, indent);
//    FirstCondition := False;
//  end;

//  if (DiffColumns.Count > 0) then begin
//    FirstOR := True;
//    for i := 0 to DiffColumns.Count - 1 do begin
//      sql.append(#13#10);
//      sql.append(indent);
//
//      if (FirstOR) then begin
//        if (FirstCondition) then
//          sql.append('WHERE (')
//        else
//          sql.append(' AND ( ');
//      end
//      else begin
//        sql.append(indent);
//        sql.append(' OR ');
//      end;
//
//      sql.append('([');
//      sql.append(DiffColumns[i].ColumnName);
//      sql.append('] <> ');
//      if    (not DiffColumns[i].IsParameter)
//        and (not DiffColumns[i].IsLiteral)
//      then
//        Self.Columns[DiffColumns[i].ColumnName].BuildValue(sql, parameters)
//      else
//        DiffColumns[i].BuildValue(Sql, parameters);
//      sql.append(')');
//      FirstOR := False;
//    end;
//
//    if (not FirstOR) then
//      sql.append(')');
//  end;


end;

procedure TSQLInsertOrUpdateFactory.buildSQL(sql: TWideStringBuffer;
  parameters: TParameterList; const indent: WideString);
Var
  SelectSQL : TSQLSelectFactory;
  InsertSQL : TSQLInsertFactory;
  i : Integer;
  SvAllow : Boolean;
  Column : TFieldValueDef;
  Condition : TSimpleCondition;
begin
  if (not AllowNoConditions) and (Where.Count = 0) and (KeyColumns.Count = 0) then
    raise ESQLUpdateNoConditions.Create('No conditions on which records are to be updated have been defined.');
  if (Columns.Count = 0) then
    raise ESQLUpdateNoColumns.Create('No columns have been defined for updating.');

  sql.Append(indent);
  if (InsertOnly) then
    sql.Append('IF NOT EXISTS (')
  else
    sql.Append('IF EXISTS (');
  SelectSQL := TSQLSelectFactory.Create(Self);
  try
    SelectSQL.FromTable.Assign(UpdateTable);
    SelectSQL.TopCount := 1;

    for i := 0 to KeyColumns.Count - 1 do begin
      Column := Columns[KeyColumns[i]];
      if (Column = nil) then
        Raise Exception.create('Key Column, "' + KeyColumns[i] + '" was not found in Columns.');

      Condition := SelectSQL.Where.Add('['+Column.ColumnName + '] = :');
      if Column.IsLiteral then begin
        Condition.LiteralValue := Column.LiteralValue;
        Condition.UseRaw := Column.UseRaw;
      end
      else begin
        Condition.Parameters.addParameters(Column.Parameters);
      end;
    end;

    SelectSQL.buildSQL(sql, parameters, indent + '           ' );

  finally
    SafeFree(SelectSQL);
  end;

  sql.Append(') '#13#10);
  if (not InsertOnly) then begin
    SvAllow := AllowNoConditions;
    try
      AllowNoConditions := True;
    // Build the UPDATE
    inherited BuildSQL(sql, parameters, indent + '    ');
    finally
      AllowNoConditions := SvAllow;
    end;
    sql.Append(#13#10);
    sql.append(Indent);
    sql.append('ELSE'#13#10);
  end;
  
  InsertSQL := TSQLInsertFactory.Create(Self);
  try
    InsertSQL.IntoTable.Assign(UpdateTable);
    InsertSQL.Columns.Assign(Columns);

    InsertSQL.buildSql(sql, parameters, indent + '    ');
  finally
    SafeFree(InsertSQL);
  end;
end;

initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLFactoryModify.pas,v $', '$Revision: 1.21 $', '$Date: 2014/09/17 11:15:32 $');
{$ENDIF}
end.



