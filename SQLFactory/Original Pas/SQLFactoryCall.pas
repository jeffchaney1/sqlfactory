{******************************************************************************
  Implementation of SQLFactory classes that call a stored procedure

  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2011/12/02 19:59:03 $
  @group Shared.SQLFactory
  @version $Id: SQLFactoryCall.pas,v 1.8 2011/12/02 19:59:03 jchaney Exp $
  @version
******************************************************************************}

unit SQLFactoryCall;

interface

uses UnitVersion, Classes, CommonStringLib, TypedList, SysUtils, PRADODB, PRADODB, ADODB;

type
  ESQLFactoryException = class(Exception) end;

  TSQLSelectFactory = class;

//  TParameterType = (ftString, ftInteger, ftBoolean, ftDouble, ftDateTime, ftUnknown);
  TParameter = class
  private
    fValue : Variant;
    fDataType : TDataType;
    fDirection : TParameterDirection;
  public
    property Value : Variant read fValue write fValue;
    property DataType : TDataType read fDataType write fDataType;
    property Direction : TParameterDirection read fDirection write fDirection;
  end;

  TParameterList = class(TCustomTypedList)
  protected
    function GetItem(Index : Integer) : TParameter;
    function CreateParameter(Value : Variant; DataType : TDataType; Direction : TParameterDirection) : TParameter;
  public
    constructor Create;

    procedure addParameters(source : array of const); overload;
    procedure addParameters(source : TParameterList); overload;
    procedure copyTo(destination : TParameters);

    // Intermediate value is stored in a variant and Variant Reals
    //   are stored as Doubles.
    procedure addBooleanParameter(value : Boolean);
    procedure addIntegerParameter(value : Int64);
    procedure addFloatParameter(value : Double);
    procedure addStringParameter(value : WideString);
    procedure addDateTimeParameter(value : TDateTime);
    procedure addVariantParameter(value : OleVariant);
    procedure addParameter(value : TParameter);

    property Parameter[Index : Integer] : TParameter read GetItem; default;
  end;

  TSQLElement = class
  protected
    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); overload; virtual; abstract;

    procedure appendParameters(sql : TStringBuffer; parameters : TParameterList);
  public
    function buildSQL(parameters : TParameterList = nil) : WideString; overload; virtual;

    function AsString : String;
  end;

  TParameteredElement = class(TSQLElement)
  private
    fParameters : TParameterList;

  protected
    function GetParameters : TParameterList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure addParameters(parameters : array of const); overload;
    procedure addParameters(parameters : TParameterList); overload;

    // Intermediate value is stored in a variant and Variant Reals
    //   are stored as Doubles.
    procedure addBooleanParameter(value : Boolean);
    procedure addIntegerParameter(value : Int64);
    procedure addFloatParameter(value : Extended);
    procedure addStringParameter(value : WideString);
    procedure addDateTimeParameter(value : TDateTime);
    procedure addVariantParameter(Value : Variant);

    property Parameters : TParameterList read GetParameters;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;
  end;

  TTableDef = class(TParameteredElement)
  private
    fTableSchema : String;
    fTableExpression : String;
    fTableAlias : String;
  protected
    function GetTableSchema : WideString;
    function GetTableExpression : WideString;
    function GetTableAlias : WideString;
  public
    constructor Create(tableSchema : WideString; tableExpression : WideString; tableAlias : WideString); overload;
    constructor Create(tableExpression : WideString); overload;
    constructor Create(tableExpression : WideString; tableAlias : WideString); overload;

    property TableSchema : WideString read GetTableSchema;
    property TableExpression : WideString read GetTableExpression;
    property TableAlias : WideString read GetTableAlias;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;
  end;

  TFieldDef = class(TParameteredElement)
  private
    fTableAlias : String;
    fColumnExpression : String;
  protected
    function GetTableAlias : WideString;
    function GetColumnExpression : WideString;
  public
    constructor Create(columnExpression : String); overload;
    constructor Create(tableAlias : String; columnExpression : String); overload;

    property TableAlias : WideString read GetTableAlias;
    property ColumnExpression : WideString read GetColumnExpression;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;
  end;

  TCustomFieldList = class(TCustomTypedList)
  protected
    function GetField(Key : Variant) : TFieldDef;
    property Field[Key : Variant] : TFieldDef read GetField; default;

  public
    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = '');
  end;

  TFieldList = class(TCustomFieldList)
  public
    constructor Create;

    procedure AddField(Field : TFieldDef);

    property Field;
  end;

  TOrderByDef = class(TFieldDef)
  private
    fDescending : Boolean;
  protected
    function GetDescending : Boolean;
    procedure SetDescending(Value : Boolean);
  public
    constructor Create(tableAlias : WideString; columnExpression : WideString);

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;

    property Descending : Boolean read GetDescending write SetDescending;
  end;

  TGroupByDef = class(TFieldDef)
  end;

  TColumnDef = class(TFieldDef)
  private
    fColumnAlias : String;
  protected
    function GetColumnAlias : String;
  public
    constructor Create(columnExpression : String); overload;
    constructor Create(columnExpression, columnAlias : String); overload;
    constructor Create(tableAlias, columnExpression, columnAlias : String); overload;

    property ColumnAlias : String read GetColumnAlias;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;
  end;

  TColumnList = class(TCustomFieldList)
  protected
    function GetColumn(Key : Variant) : TColumnDef;
  public
    constructor Create;
    property Column[Key : Variant] : TColumnDef read GetColumn; default;

    function AddColumn(Column : TColumnDef) : TColumnDef;
    function InsertColumn(Idx : Integer; Column : TColumnDef) : TColumnDef;
  end;

  TConditionDef = class(TParameteredElement)
  private
    fWhereExpression : String;
  public
    constructor Create(whereExpression : String);

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;

  end;

  TConditionList = class(TCustomTypedList)
  protected
    function GetCondition(Idx : Integer) : TConditionDef;
  public
    constructor Create;
    function AddCondition(Condition : TConditionDef) : TConditionDef;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = '');

    property Condition[Idx : Integer] : TConditionDef read GetCondition; default;
  end;

  TORConditionDef = class(TConditionDef)
  private
    fConditions : TConditionList;
    function Conditions : TConditionList;
  public
    constructor Create(conditionExpressions : array of String);
    destructor Destroy; override;

    procedure addConditionExpression(conditionExpression : String);

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;

  end;

  TINConditionDef = class(TConditionDef)
  public
    constructor Create(columnExpression: String; subSelect : TSQLSelectFactory);
  end;

  TJoinType = (jtLeftJoin, jtJoin);

  TJoinTableDef = class(TTableDef)
  private
    fJoinType : TJoinType;
    fJoinOnConditions : TConditionList;
  protected
    function GetJoinOnConditions : TConditionList;
  public
    constructor Create(joinTableExpression, joinTableAlias, joinOnExpression : String; joinType : TJoinType = jtJoin);
    destructor Destroy; override;

    function addJoinOn(expression : String) : TConditionDef; overload;
    function addJoinOn(condition : TConditionDef) : TConditionDef; overload;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;

    procedure SetJoinType(value : TJoinType);

    property JoinOnConditions : TConditionList read GetJoinOnConditions;
    property JoinType : TJoinType read fJoinType write SetJoinType;
  end;

  TJoinTableList = class(TCustomTypedList)
  protected
    function GetJoinTable(Idx: Integer): TJoinTableDef;
    function GetJoinTableByAlias(alias : String) : TJoinTableDef;
  public
    constructor Create;
    function AddJoinTable(JoinTable : TJoinTableDef) : TJoinTableDef;

    property JoinTable[Idx : Integer] : TJoinTableDef read GetJoinTable; default;
    property JoinTableByAlisa[Alias : String] : TJoinTableDef read GetJoinTableByAlias;
  end;

  TSQLSelectFactory = class(TSQLElement)
  private
    fFromTable : TTableDef;
    fSubSelectParameters : TParameterList;
    fTopCount : Integer;
    fColumns : TColumnList;
    fJoinTos : TJoinTableList;
    fWhereClauses : TConditionList;
    fHavingClauses : TConditionList;
    fOrderBys : TColumnList;
    fGroupBys : TColumnList;
  protected
    function SubSelectParameters : TParameterList;

    function GetFromTable : TTableDef;
    function GetColumns : TColumnList;
    function GetJoinTos : TJoinTableList;
    function GetWhereClauses : TConditionList;
    function GetHavingClauses : TConditionList;
    function GetOrderBys : TColumnList;
    function GetGroupBys : TColumnList;
    function GetTopCount: Integer;
    procedure SetTopCount(const Value: Integer);
  public
    constructor Create(tableExpression : String; tableAlias : String = ''); overload;
    constructor Create(tableSchema, tableExpression, tableAlias : String); overload;
    destructor Destroy; override;

    property fromTable : TTableDef read GetfromTable;
    function setFromTable(tableExpression : String; tableAlias : String = ''): TTableDef; overload;
    function setFromTable(tableSchema, tableExpression, tableAlias : String): TTableDef; overload;
    function setFromTable(subSelect : TSQLSelectFactory; tableAlias : String): TTableDef; overload;

    property Columns : TColumnList read GetColumns;
    function addColumn(columnExpression : String; columnName : String = '') : TColumnDef;
    procedure addColumns(columnInfo : array of string);
    function insertColumn(columnPos : Integer; columnExpression : String; columnName : String = '') : TColumnDef;
    procedure insertColumns(columnPos : Integer; columnInfo : array of string);

    property JoinTos : TJoinTableList read GetJoinTos;
    function addJoinTo(subSelect : TSQLSelectFactory; joinToAlias : String; joinOnExpression : String) : TJoinTableDef; overload;
    function addJoinTo(joinTableExpression, joinOnExpression : String) : TJoinTableDef; overload;
    function addJoinTo(joinTableExpression, joinToAlias, joinOnExpression : String) : TJoinTableDef; overload;
    procedure addJoinTos(joinToInfo : array of string);

    property WhereClauses : TConditionList read GetWhereClauses;
    function addWhere(whereExpression : String) : TConditionDef;
    function addWhereOR(whereExpressions : array of String) : TConditionDef;
    function addWhereIN(columnExpression : String; subSelect : TSQLSelectFactory) : TConditionDef;

    property HavingClauses : TConditionList read GetHavingClauses;
    function addHaving(HavingExpression : String) : TConditionDef;

    property OrderBys : TColumnList read GetOrderBys;
    function addOrderBy(column : TColumnDef) : TColumnDef; overload;
    function addOrderBy(columnExpression : String) : TColumnDef; overload;
    function insertOrderBy(orderPosition : Integer; column : TColumnDef) : TColumnDef; overload;
    function insertOrderBY(orderPosition : Integer; columnExpression : String) : TColumnDef; overload;

    property GroupBys : TColumnList read GetGroupBys;
    function addGroupBy(column : TColumnDef) : TColumnDef; overload;
    function addGroupBy(columnExpression : String) : TColumnDef; overload;
    function insertGroupBy(orderPosition : Integer; column : TColumnDef) : TColumnDef; overload;
    function insertGroupBy(orderPosition : Integer; columnExpression : String) : TColumnDef; overload;

    property TopCount : Integer read GetTopCount write SetTopCount;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;

    function prepareQuery(Connection : TPRADOConnection; ExecuteOptions : TExecuteOptions = []; Open : WordBool = true) : TPRADOQuery;
  end;

  TSQLCallFactory = class(TParameteredElement)
  private
    fProcedureName : String;
    fHasReturnValue : Boolean;
  public
    constructor Create(ProcedureName : String; hasReturnValue : Boolean = false); overload;
    function AddOutputParameter(DataType : TDataType)  : TParameteredElement;

    property ProcedureName : String read fProcedureName write fProcedureName;
    property HasReturnValue : Boolean read fHasReturnValue write fHasReturnValue;


    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;

    function prepareCALL(Connection : TPRADOConnection; ExecuteOptions : TExecuteOptions = [];
                          Execute : WordBool = true) : TPRADOStoredProc;
    function Execute(Connection : TPRADOConnection;  ExecuteOptions : TExecuteOptions = [];
                          Execute : WordBool = true) : integer;
  end;

  TInsertFieldDef = class(TFieldDef)
  private
    fLiteralValue : TParameter;
    fColumnName : String;
  protected
    function getLiteralValue : Variant;
    procedure SetLiteralValue(Value : Variant);
    function GetColumnName : String;
    procedure SetColumnName(Value : String);
    function GetIsLiteral : WordBool;
    function GetIsParameter : WordBool;

  public
    constructor Create(fieldName : String; literalValue : Variant); overload;
    constructor Create(fieldName : String); overload;

    property LiteralValue : Variant read GetLiteralValue write SetLiteralValue;
    property ColumnName : String read GetColumnName write SetColumnName;
    property IsLiteral : WordBool read GetIsLiteral;
    property IsParameter : WordBool read GetIsParameter;

    procedure buildSQL(sql : TStringBuffer; parameters : TParameterList; indent : String = ''); override;
    procedure BuildInsertValue(sql : TStringBuffer; parameters : TParameterList);
    class function BuildValuesList(sql : TStringBuffer; columns : TCustomFieldList; parameters : TParameterList; Indent : String) : Boolean;
  end;

  TInsertFieldList = class(TCustomFieldList)
  protected
    function GetColumn(Key : Variant) : TInsertFieldDef;
  public
    constructor Create;
    property Column[Key : Variant] : TInsertFieldDef read GetColumn; default;

    function AddColumn(Column : TInsertFieldDef) : TInsertFieldDef;
    function InsertColumn(Idx : Integer; Column : TInsertFieldDef) : TInsertFieldDef;
  end;

  TSQLInsertFactory = class(TSQLElement)
  private
    fIntoTable : TTableDef;
    fColumns : TInsertFieldList;

    fFromTable : TTableDef;
    fSubSelectParameters : TParameterList;

  protected
    function GetIntoTable : TTableDef;
    function GetFromTable : TTableDef;
    function GetColumns : TInsertFieldList;
    function SubSelectParameters: TParameterList;

  public
    constructor Create(tableExpression : String; tableAlias : String = ''); overload;
    constructor Create(tableSchema, tableExpression, tableAlias : String); overload;
    destructor Destroy; override;

    property intoTable : TTableDef read GetIntoTable;
    function setIntoTable(tableExpression : String; tableAlias : String = ''): TTableDef; overload;
    function setIntoTable(tableSchema, tableExpression, tableAlias : String): TTableDef; overload;

    property fromTable : TTableDef read GetfromTable;
    function setFromTable(tableExpression : String; tableAlias : String = ''): TTableDef; overload;
    function setFromTable(tableSchema, tableExpression, tableAlias : String): TTableDef; overload;
    function setFromTable(subSelect : TSQLSelectFactory; tableAlias : String): TTableDef; overload;

    property Columns : TInsertFieldList read GetColumns;
    function addColumn(columnName : String) : TInsertFieldDef; overload;
    function addColumn(columnName : String; literalValue : OleVariant) : TInsertFieldDef; overload;

    procedure addColumns(columnInfo : array of string);
    function insertColumn(columnPos : Integer; columnName : String) : TInsertFieldDef;
    procedure insertColumns(columnPos : Integer; columnInfo : array of string);

  end;

const
  STD_INDENT = '    ';


implementation

uses Math,  CommonObjLib, Variants, DB;

{ TParameterList }

constructor TParameterList.Create;
begin
  inherited;
  ControlLife := True;
  Sorted := False;
end;

function TParameterList.GetItem(Index: Integer): TParameter;
begin
  Result := TParameter(_GetItem(Index));
end;

function TParameterList.CreateParameter(Value : Variant; DataType : TDataType; Direction : TParameterDirection) : TParameter;
begin
  Result := TParameter.Create;
  Result.Value := Value;
  Result.DataType := DataType;
  Result.Direction := Direction;

  _AddItem(Result);
end;

procedure TParameterList.addBooleanParameter(value: Boolean);
begin
  CreateParameter(Value, ftBoolean, pdInput);
end;

procedure TParameterList.addIntegerParameter(value: Int64);
begin
  CreateParameter(Value, ftInteger, pdInput);
end;

procedure TParameterList.addFloatParameter(value: Double);
begin
  CreateParameter(Value,ftFloat, pdInput);
end;

procedure TParameterList.addStringParameter(value: WideString);
begin
  CreateParameter(Value,ftWideString, pdInput);
end;

procedure TParameterList.addDateTimeParameter(value: TDateTime);
begin
  CreateParameter(Value,ftDateTime, pdInput);
end;

procedure TParameterList.addVariantParameter(value : OleVariant);
begin
  CreateParameter(Value, VarTypeToDataType(VarType(Value)), pdInput);
end;

procedure TParameterList.addParameter(value : TParameter);
begin
  CreateParameter(Value.Value,Value.DataType, Value.Direction);
end;

procedure TParameterList.addParameters(source: TParameterList);
Var
  i : Integer;
begin
  for i := 0 to source.Count - 1 do
    CreateParameter(source[i].Value, source[i].DataType, source[i].Direction);
end;

procedure TParameterList.copyTo(destination : TParameters);
Var
  i : Integer;
begin
  for i := 0 to Count - 1 do begin
    destination.CreateParameter('', Self[i].DataType,
      Self[i].Direction, 0, Self[i].Value);
  end;
end;

procedure TParameterList.addParameters(source: array of const);
Var
  i : Integer;
begin
  for i := Low(source) to High(source) do
    case source[i].VType of
      vtInteger:    addIntegerParameter(source[i].VInteger);
      vtBoolean:    addBooleanParameter(source[i].VBoolean);
      vtChar:       addStringParameter(source[i].VChar);
      vtExtended:   addFloatParameter(source[i].VExtended^);
      vtString:     addStringParameter(source[i].VString^);
      vtPChar:      addStringParameter(source[i].VPChar);
      vtWideChar:   addStringParameter(source[i].VWideChar);
      vtPWideChar:  addStringParameter(source[i].VPWideChar);
      vtAnsiString: addStringParameter(AnsiString(source[i].VAnsiString));
      vtCurrency:   addFloatParameter(source[i].VCurrency^);
      vtVariant:    addVariantParameter(source[i].VVariant^);
      vtWideString: addStringParameter(WideString(source[i].VWideString));
      vtInt64:      addIntegerParameter(Int64(source[i].VInt64^));
      else
        // Do nothing with these types
        //vtClass:      (VClass: TClass);
        //vtInterface:  (VInterface: Pointer);
        //vtObject:     (VObject: TObject);
        //vtPointer:    (VPointer : Pointer);
    end;
end;

{ TSQLElement }

procedure TSQLElement.appendParameters(sql: TStringBuffer; parameters: TParameterList);
  function _VarAsString(V : Variant) : String;
  begin
    try
      Result := VarToLiteralValue(V);
    except
      Result := 'Convert Error: ' + VarTypeAsText(VarType(v));
    end;
  end;
Var
  i : Integer;
begin
  sql.append(' parameters (');
  if (parameters.Count > 0) then begin
    sql.append(_VarAsString(parameters[0].Value));
    for i := 1 to parameters.Count - 1 do begin
      sql.append(',');
      sql.append(_VarAsString(parameters[i].Value));
    end;
  end;
  sql.append(')');
end;

function TSQLElement.AsString: String;
Var
  parameters : TParameterList;
  sql : TStringBuffer;
begin
  parameters := TParameterList.Create;
  sql := TStringBuffer.Create;
  try
    buildSQL(sql, parameters, '');
    appendParameters(sql, parameters);
    Result := sql.toString;
  finally
    SafeFree(parameters);
    SafeFree(sql);
  end;
end;

function TSQLElement.buildSQL(parameters : TParameterList = nil) : WideString;
Var
  sql : TStringBuffer;
  localParms : Boolean;
begin
  localParms := false;
  sql := TStringBuffer.Create;
  if (parameters = nil) then begin
    parameters := TParameterList.Create;
    localParms := True;
  end;
  try
    buildSQL(sql, parameters, '');
    if (localParms) and (parameters.Count > 0) then
      raise ESQLFactoryException.Create('This SQL contains parameters, but no ' +
                                       'parameter list was given to collect them.');
    Result := sql.toString;
  finally
    safeFree(sql);
    if (localParms) then
      safeFree(parameters);
  end;

end;

{ TParameteredElement }

constructor TParameteredElement.Create;
begin
  inherited;

end;

destructor TParameteredElement.Destroy;
begin
  SafeFree(fParameters);
  inherited;
end;

function TParameteredElement.GetParameters: TParameterList;
begin
  if (not Assigned(fParameters)) then
    fParameters := TParameterList.Create;
  Result := fParameters;
end;

procedure TParameteredElement.addFloatParameter(value: Extended);
begin
  Parameters.addFloatParameter(value);
end;

procedure TParameteredElement.addStringParameter(value: WideString);
begin
  Parameters.addStringParameter(Value);
end;

procedure TParameteredElement.addBooleanParameter(value: Boolean);
begin
  Parameters.addBooleanParameter(Value);
end;

procedure TParameteredElement.addIntegerParameter(value: Int64);
begin
  Parameters.addIntegerParameter(Value);
end;

procedure TParameteredElement.addDateTimeParameter(value : TDateTime);
begin
  Parameters.addDateTimeParameter(Value);
end;


procedure TParameteredElement.addVariantParameter(Value : Variant);
begin
  Self.Parameters.addVariantParameter(Value);
end;

procedure TParameteredElement.addParameters(parameters : TParameterList);
begin
  Self.Parameters.addParameters(parameters);
end;

procedure TParameteredElement.addParameters(parameters: array of const);
begin
  Self.Parameters.addParameters(parameters);
end;

procedure TParameteredElement.buildSQL(sql: TStringBuffer;  parameters: TParameterList; indent : String = '');
begin
  if (parameters <> nil) then
    parameters.addParameters(Self.Parameters);
end;


{ TTableDef }

constructor TTableDef.Create(tableSchema, tableExpression,
  tableAlias: WideString);
Var
  p : Integer;
begin
  inherited Create;

  if (Pos('SELECT', UpperCase(tableExpression)) > 0) then begin
    if (Copy(alltrim(tableExpression), 1, 1) <> '(') then
      fTableExpression := '(' + AllTrim(tableExpression) + ')'
    else
      fTableExpression := AllTrim(tableExpression);
    fTableSchema := AllTrim(tableSchema);
    fTableAlias := AllTrim(tableAlias);
  end
  else begin
    p := Pos('.', tableExpression);
    if ((tableSchema = '') and (p > 0)) then begin
      fTableExpression := AllTrim(copy(tableExpression, p + 1, 1024));
      fTableSchema := AllTrim(copy(tableExpression, 1, p - 1));
    end
    else begin
      fTableExpression := allTrim(tableExpression);
      fTableSchema := AllTrim(tableSchema);
    end;
    if (TableAlias = '') then // and (fTableSchema <> '') then
      fTableAlias := AllTrim(fTableExpression)
    else
      fTableAlias := AllTrim(tableAlias);
  end;
end;

constructor TTableDef.Create(tableExpression: WideString);
begin
  Create('', tableExpression, '');
end;

constructor TTableDef.Create(tableExpression, tableAlias: WideString);
begin
  Create('', tableExpression, tableAlias);
end;

function TTableDef.GetTableAlias: WideString;
begin
  Result := fTableAlias;
end;

function TTableDef.GetTableExpression: WideString;
begin
  Result := fTableExpression;
end;

function TTableDef.GetTableSchema: WideString;
begin
  Result := fTableSchema;
end;

procedure TTableDef.buildSQL(sql: TStringBuffer; parameters: TParameterList;
  indent : String = '');
begin
  if (tableSchema <> '') then begin
    sql.append(tableSchema);
    sql.append('.');
  end;

  sql.append(tableExpression);

  if (tableAlias <> '') then begin
    sql.append(' ');
    sql.append(tableAlias);
  end;

  inherited buildSQL(sql, parameters, indent);

end;

{ TFieldDef }

constructor TFieldDef.Create(columnExpression: String);
begin
  Create('', columnExpression);
end;

constructor TFieldDef.Create(tableAlias, columnExpression: String);
Var
  p : Integer;
begin
  inherited Create;
  if (tableAlias <> '') then begin
    fTableAlias := tableAlias;
    fColumnExpression := columnExpression;
  end
  else begin
    p := Pos('.', columnExpression);
    if (p > 0) then begin
      fTableAlias := Copy(columnExpression, 1, p -1);
      fColumnExpression := Copy(columnExpression, p + 1, 1024);
    end
    else begin
      fTableAlias := '';
      fColumnExpression := columnExpression;
    end;
  end;
end;

function TFieldDef.GetTableAlias: WideString;
begin
  Result := fTableAlias;
end;

function TFieldDef.GetColumnExpression: WideString;
begin
  Result := fColumnExpression;
end;

procedure TFieldDef.buildSQL(sql: TStringBuffer; parameters: TParameterList; indent : String = '');
begin
  if (tableAlias <> '') then begin
    sql.append(tableAlias);
    sql.append('.');
  end;

  sql.append(columnExpression);
end;

{ TCustomFieldList }

function TCustomFieldList.GetField(Key : Variant): TFieldDef;
begin
  Result := TFieldDef(_GetItem(Key));
end;

procedure TCustomFieldList.buildSQL(sql: TStringBuffer; parameters: TParameterList;
  indent : String = '');
Var
  i : Integer;
  fieldsWithoutBreak : Integer;
  fieldText : String;
begin
  if (Self.Count = 0) then Exit;
  fieldsWithoutBreak := 0;
  sql.append(Self.Field[0].buildSQL);
  for i := 1 to Self.Count - 1 do begin
    sql.append(', ');
    if (fieldsWithoutBreak > 3) then begin
      sql.append(#13#10);
      sql.append(indent);
      sql.append(STD_INDENT);
      fieldsWithoutBreak := 0;
    end;
    fieldText := Self.Field[i].buildSQL;
    sql.append(fieldText);
    inc(fieldsWithoutBreak);
    if (Pos(#13, fieldText) > 0) then
      fieldsWithoutBreak := 0

  end;
end;

{ TFieldList }

constructor TFieldList.Create;
begin
  inherited Create;
  Sorted := False;
  ControlLife := True;
end;

procedure TFieldList.AddField(Field: TFieldDef);
begin
  _AddItem(Field);
end;

{ TOrderByDef }

constructor TOrderByDef.Create(tableAlias, columnExpression: WideString);
begin
  inherited;

  fDescending := False;
end;

function TOrderByDef.GetDescending: Boolean;
begin
  Result := fDescending;
end;

procedure TOrderByDef.SetDescending(Value: Boolean);
begin
  fDescending := Value;
end;

procedure TOrderByDef.buildSQL(sql: TStringBuffer; parameters: TParameterList; indent : String = '');
begin
  inherited buildSQL(sql, parameters, indent);
  if (descending) then
    sql.append(' DESC ');
end;

{ TColumnDef }

constructor TColumnDef.Create(columnExpression: String);
begin
  Create('', columnExpression, '');
end;

constructor TColumnDef.Create(columnExpression, columnAlias: String);
begin
  Create('', columnExpression, columnAlias);
end;

constructor TColumnDef.Create(tableAlias, columnExpression, columnAlias : String);
begin
  inherited Create(tableAlias, columnExpression);

  if (columnAlias = '') then
    fColumnAlias := Self.columnExpression
  else
    fColumnAlias := columnAlias;
end;

function TColumnDef.GetColumnAlias: String;
begin
  Result := fColumnAlias;
end;

procedure TColumnDef.buildSQL(sql: TStringBuffer; parameters: TParameterList;
  indent : String = '');
begin
  inherited BuildSQL(Sql, parameters, indent);
  if (columnExpression <> columnAlias) then begin
    sql.append(' ');
    sql.append(columnAlias);
  end;
end;

{ TColumnList }

constructor TColumnList.Create;
begin
  inherited Create;
  Sorted := False;
  ControlLife := True;
  CaselessKeys := True;
end;

function TColumnList.GetColumn(Key : Variant): TColumnDef;
begin
  Result := TColumnDef(_GetItem(Key));
end;

function TColumnList.AddColumn(Column: TColumnDef) : TColumnDef;
begin
  _AddItem(Column.columnAlias, Column);
  Result := Column;
end;

function TColumnList.InsertColumn(Idx: Integer; Column: TColumnDef) : TColumnDef;
begin
  _AddItem(Idx, Column.columnAlias, Column);
  Result := Column;
end;

{ TConditionDef }

constructor TConditionDef.Create(whereExpression: String);
begin
  inherited Create;
  fWhereExpression := AllTrim(whereExpression);
end;

procedure TConditionDef.buildSQL(sql: TStringBuffer;
  parameters: TParameterList; indent : String = '');
begin
  sql.append(fWhereExpression);
  inherited buildSQL(sql, parameters, indent);
end;

{ TConditionList }
constructor TConditionList.Create;
begin
  inherited Create;
  Sorted := False;
  ControlLife := True;
end;

function TConditionList.AddCondition(Condition: TConditionDef): TConditionDef;
begin
  _AddItem(Condition);
  Result := Condition;
end;

function TConditionList.GetCondition(Idx: Integer): TConditionDef;
begin
  Result := TConditionDef(_GetItem(Idx));
end;

procedure TConditionList.buildSQL(sql: TStringBuffer;
  parameters: TParameterList; indent : String = '');
Var
  i : Integer;
begin
  if (Self.Count > 0) then begin
    sql.append(Self.Condition[0].buildSQL(parameters));

    for i := 1 to Self.Count - 1 do begin
      sql.append(#13);
      sql.append(indent);
      sql.append(' AND ');
      sql.append(Self.Condition[i].buildSQL(parameters));
    end;
  end;
end;

{ TORConditionDef }

constructor TORConditionDef.Create(conditionExpressions: array of String);
Var
  i : Integer;
begin
  inherited Create(conditionExpressions[0]);
  for i := 1 to High(conditionExpressions) do
    conditions.AddCondition(TConditionDef.Create(conditionExpressions[i]));
end;

destructor TORConditionDef.Destroy;
begin
  SafeFree(fConditions);

  inherited;
end;

function TORConditionDef.Conditions: TConditionList;
begin
  if (fConditions = nil) then
    fConditions := TConditionList.Create;

  Result := fConditions;
end;

procedure TORConditionDef.addConditionExpression(
  conditionExpression: String);
begin
  conditions.AddCondition(TConditionDef.Create(conditionExpression));
end;

procedure TORConditionDef.buildSQL(sql: TStringBuffer;
  parameters: TParameterList; indent : String = '');
Var
  i : Integer;
begin
  sql.append('((');
  inherited buildSQL(sql, parameters, indent);
  for i := 0 to conditions.Count - 1 do begin
    sql.append(') OR (');
    conditions[i].buildSQL(sql, parameters, indent);
  end;
  sql.append('))');

end;

{ TINConditionDef }

constructor TINConditionDef.Create(columnExpression: String;
  subSelect: TSQLSelectFactory);
Var
  subSelectParms : TParameterList;
  sql : TStringBuffer;
begin
  subSelectParms := TParameterList.Create;
  sql := TStringBuffer.Create;
  try
    subSelect.buildSQL(sql, subSelectParms, '');
    inherited Create(columnExpression + ' IN (' + sql.toString + ')');
    Self.addParameters(subSelectParms);
  finally
    safefree(subSelectParms);
    safeFree(sql);
  end;


end;

{ TJoinTableDef }

constructor TJoinTableDef.Create(joinTableExpression, joinTableAlias,
  joinOnExpression: String; joinType: TJoinType = jtJoin);
begin
  inherited Create(joinTableExpression, joinTableAlias);
  addJoinOn(joinOnExpression);
  setJoinType(joinType);
end;

destructor TJoinTableDef.Destroy;
begin
  SafeFree(fJoinOnConditions);

  inherited;
end;

function TJoinTableDef.GetJoinOnConditions: TConditionList;
begin
  if (fJoinOnConditions = nil) then
    fJoinOnConditions := TConditionList.Create;
  Result := fJoinOnConditions;
end;

function TJoinTableDef.addJoinOn(expression: String): TConditionDef;
begin
  Result := addJoinOn(TConditionDef.Create(expression));
end;

function TJoinTableDef.addJoinOn(condition: TConditionDef): TConditionDef;
begin
  JoinOnConditions.AddCondition(condition);
  Result := condition;
end;

procedure TJoinTableDef.SetJoinType(value: TJoinType);
begin
  fJoinType := Value;
end;

procedure TJoinTableDef.buildSQL(sql: TStringBuffer;
  parameters: TParameterList; indent : String = '');
begin
  if (joinType = jtLeftJoin) then
    sql.append(' LEFT OUTER JOIN ')
  else
    sql.append(' JOIN ');

  inherited buildSQL(sql, parameters, indent);

  sql.append(' ON ');

  joinOnConditions.buildSQL(sql, parameters, indent);
end;

{ TJoinTableList }
constructor TJoinTableList.Create;
begin
  inherited Create;
  Sorted := False;
  ControlLife := True;
  CaselessKeys := True;
end;

function TJoinTableList.AddJoinTable(
  JoinTable: TJoinTableDef): TJoinTableDef;
begin
  _AddItem(JoinTable.TableAlias, JoinTable);
  Result := JoinTable;
end;

function TJoinTableList.GetJoinTable(Idx: Integer): TJoinTableDef;
begin
  Result := TJoinTableDef(_GetItem(Idx));
end;

function TJoinTableList.GetJoinTableByAlias(alias: String): TJoinTableDef;
begin
  Result := TJoinTableDef(_GetItem(alias));
end;

{ TSQLSelectFactory }

constructor TSQLSelectFactory.Create(tableExpression, tableAlias: String);
begin
  Create('', tableExpression, tableAlias);

end;

constructor TSQLSelectFactory.Create(tableSchema, tableExpression, tableAlias: String);
begin
  inherited Create;
  setFromTable(tableSchema, tableExpression, tableAlias);
end;

destructor TSQLSelectFactory.Destroy;
begin
  SafeFree(fFromTable);
  SafeFree(fSubSelectParameters);
  SafeFree(fColumns);
  SafeFree(fJoinTos);
  SafeFree(fWhereClauses);
  SafeFree(fHavingClauses);
  SafeFree(fOrderBys);
  SafeFree(fGroupBys);
  inherited;
end;

function TSQLSelectFactory.SubSelectParameters: TParameterList;
begin
  if (fSubSelectParameters = nil) then
    fSubSelectParameters := TParameterList.Create;

  Result := fSubSelectParameters;
end;

function TSQLSelectFactory.GetfromTable: TTableDef;
begin
  if (fFromTable = nil) then begin
    fFromTable := TTableDef.Create;
  end;

  Result := fFromTable;
end;

function TSQLSelectFactory.setFromTable(tableExpression : String; tableAlias : String = '') : TTableDef;
begin
  Result := setFromTable('', tableExpression, tableAlias);
end;

function TSQLSelectFactory.setFromTable(tableSchema, tableExpression, tableAlias: String) : TTableDef;
begin
  subSelectParameters.clear;
  if (fFromTable <> nil) then
    SafeFree(fFromTable);

  fFromTable := TTableDef.Create(tableSchema, tableExpression, tableAlias);
  Result := fFromTable;
end;

function TSQLSelectFactory.setFromTable(subSelect: TSQLSelectFactory; tableAlias: String) : TTableDef;
Var
  parms : TParameterList;
  sql : TStringBuffer;
begin
  parms := TParameterList.Create;
  sql := TStringBuffer.Create;
  try
    sql.append('(');
    subSelect.buildSQL(sql, parms, STD_INDENT);
    sql.append(')');

    Result := setFromTable(sql.toString, tableAlias);
    subSelectParameters.addParameters(parms);
  finally
    SafeFree(parms);
    SafeFree(sql);
  end;
end;

function TSQLSelectFactory.GetColumns: TColumnList;
begin
  if (fColumns = nil) then
    fColumns := TColumnList.Create;

  Result := fColumns;
end;

function TSQLSelectFactory.addColumn(columnExpression,
  columnName: String): TColumnDef;
begin
  Result := insertColumn(columns.Count, columnExpression, columnName);
end;

procedure TSQLSelectFactory.addColumns(columnInfo: array of string);
begin
  insertColumns(columns.Count, columnInfo);
end;

function TSQLSelectFactory.insertColumn(columnPos: Integer;
  columnExpression, columnName: String): TColumnDef;
begin
  Result := TColumnDef.Create(columnExpression, columnName);
  columns.InsertColumn(columnPos, Result);
end;

procedure TSQLSelectFactory.insertColumns(columnPos: Integer;
  columnInfo: array of string);
Var
  i, p : Integer;
  tmpColumnExpression, tmpColumnName : String;
begin
  for i := High(columnInfo) downto 0 do begin
    p := 1;
    tmpColumnExpression := ParseNext(p, columnInfo[i], ', ', '"[]');
    tmpColumnName := ParseNext(p, columnInfo[i], ', ', '"[]');
    insertColumn(columnPos, tmpColumnExpression, tmpColumnName);
  end;
end;

function TSQLSelectFactory.GetJoinTos: TJoinTableList;
begin
  if (fJoinTos = nil) then
    fJoinTos := TJoinTableList.Create;

  result := fJoinTos;
end;

function TSQLSelectFactory.addJoinTo(subSelect: TSQLSelectFactory;
  joinToAlias, joinOnExpression: String): TJoinTableDef;
Var
  sql : TStringBuffer;
  parms : TParameterList;
begin
  sql := TStringBuffer.Create;
  parms := TParameterList.Create;
  try
    sql.append('(');
    subSelect.buildSQL(sql, parms, STD_INDENT);
    sql.append(')');

    Result := addJoinTo(sql.toString, joinToAlias, joinOnExpression);
    Result.Parameters.addParameters(parms);
  finally
    safeFree(sql);
    safeFree(parms);
  end;
end;

function TSQLSelectFactory.addJoinTo(joinTableExpression,
  joinOnExpression: String): TJoinTableDef;
begin
  Result := addJoinTo(joinTableExpression, joinTableExpression, joinOnExpression);
end;

function TSQLSelectFactory.addJoinTo(joinTableExpression, joinToAlias,
  joinOnExpression: String): TJoinTableDef;
begin
  Result := TJoinTableDef.Create(joinTableExpression, joinToAlias, joinOnExpression);
  joinTos.AddJoinTable(Result);
end;

procedure TSQLSelectFactory.addJoinTos(joinToInfo: array of string);
Var
  i, p : Integer;
  tmpTable, tmpAlias, tmpExpr : String;
begin
  for i := 0 to High(joinToInfo) do begin
    p := 1;
    tmpTable := ParseNext(p, joinToInfo[i], ', ', '"[]');
    tmpAlias := ParseNext(p, joinToInfo[i], ',', '"[]');
    tmpExpr := ParseNext(p, joinToInfo[i], ',', '"[]');
    if (tmpExpr = '') and (tmpAlias <> '') then begin
      tmpExpr := tmpAlias;
      tmpAlias := '';
    end;
    addJoinTo(tmpTable, tmpAlias, tmpExpr);
  end;
end;

function TSQLSelectFactory.GetWhereClauses: TConditionList;
begin
  if (fWhereClauses = nil) then
    fWhereClauses := TConditionList.Create;

  Result := fWhereClauses;
end;

function TSQLSelectFactory.addWhere(whereExpression: String): TConditionDef;
begin
  Result := WhereClauses.AddCondition(TConditionDef.Create(whereExpression));
end;

function TSQLSelectFactory.addWhereIN(columnExpression: String; subSelect: TSQLSelectFactory): TConditionDef;
begin
  Result := WhereClauses.AddCondition(TINConditionDef.Create(columnExpression, subSelect));
end;

function TSQLSelectFactory.addWhereOR(whereExpressions: array of String): TConditionDef;
begin
  Result := WhereClauses.AddCondition(TORConditionDef.Create(whereExpressions));
end;

function TSQLSelectFactory.GetHavingClauses: TConditionList;
begin
  if (fHavingClauses = nil) then
    fHavingClauses := TConditionList.Create;

  Result := fHavingClauses;
end;

function TSQLSelectFactory.addHaving(HavingExpression: String): TConditionDef;
begin
  Result := havingClauses.AddCondition(TConditionDef.Create(havingExpression));
end;

function TSQLSelectFactory.GetOrderBys: TColumnList;
begin
  if (fOrderBys = nil) then
    fOrderBys := TColumnList.Create;

  Result := fOrderBys;
end;

function TSQLSelectFactory.addOrderBy(columnExpression: String): TColumnDef;
begin
  Result := insertOrderBy(OrderBys.Count, columnExpression);
end;

function TSQLSelectFactory.addOrderBy(column: TColumnDef): TColumnDef;
begin
  Result := insertOrderBy(orderBys.Count, column);
end;

function TSQLSelectFactory.insertOrderBy(orderPosition: Integer;
  columnExpression: String): TColumnDef;
begin
  Result := OrderBys.insertColumn(orderPosition, TColumnDef.Create(columnExpression));
end;

function TSQLSelectFactory.insertOrderBy(orderPosition: Integer;
  column: TColumnDef): TColumnDef;
begin
  if (column = nil) then begin
    Result := nil;
    Exit;
  end;
  // We don't want to use the actual column definition because it may
  // contain an alias and it's life is controlled by its own
  // column list.
  if (column.TableAlias <> '') then
    Result := insertOrderBy(orderPosition, column.TableAlias + '.' + column.ColumnExpression)
  else
    Result := insertOrderBy(orderPosition, column.ColumnExpression);
end;

function TSQLSelectFactory.GetGroupBys: TColumnList;
begin
  if (fGroupBys = nil) then
    fGroupBys := TColumnList.Create;

  Result := fGroupBys;
end;

function TSQLSelectFactory.addGroupBy(columnExpression: String): TColumnDef;
begin
  Result := insertGroupBy(groupBys.Count, columnExpression);
end;

function TSQLSelectFactory.addGroupBy(column: TColumnDef): TColumnDef;
begin
  Result := insertGroupBy(groupBys.Count, column);
end;

function TSQLSelectFactory.insertGroupBy(orderPosition: Integer;
  columnExpression: String): TColumnDef;
begin
  Result := groupBys.InsertColumn(orderPosition, TColumnDef.Create(columnExpression));
end;

function TSQLSelectFactory.insertGroupBy(orderPosition: Integer; column: TColumnDef): TColumnDef;
begin
  if (column = nil) then begin
    Result := nil;
    Exit;
  end;
  // We don't want to use the actual column definition because it may
  // contain an alias and it's life is controlled by its own
  // column list.
  if (column.TableAlias <> '') then
    Result := insertGroupBy(orderPosition, column.TableAlias + '.' + column.ColumnExpression)
  else
    Result := insertGroupBy(orderPosition, column.ColumnExpression);
end;

function TSQLSelectFactory.GetTopCount: Integer;
begin
  Result := fTopCount;
end;

procedure TSQLSelectFactory.SetTopCount(const Value: Integer);
begin
  fTopCount := Value;
end;

procedure TSQLSelectFactory.buildSQL(sql: TStringBuffer; parameters: TParameterList; indent: String = '');
Var
  i : Integer;
  newLine : Boolean;
begin
  sql.append(indent);
  sql.append('SELECT ');
  if (topCount > 0) then begin
    sql.append(' TOP ');
    sql.append(IntToStr(topCount));
    sql.append(' ');
  end;

  if (columns.Count > 0) then begin
    columns.buildSQL(sql, parameters, indent);
    sql.append(#13#10);
    sql.append(indent);
  end
  else
    sql.append('* ');

  sql.append('FROM ');
  fromTable.buildSQL(sql, nil, '');
  parameters.addParameters(subSelectParameters);
  newLine := False;

  for i := 0 to joinTos.count -1 do begin
    if not newLine then begin
      sql.append(#13#10);
      sql.append(indent);
    end;
    joinTos[i].buildSQL(sql, parameters, indent);
  end;

  if (whereClauses.Count > 0) then begin
    if not newLine then begin
      sql.append(#13#10);
      sql.append(indent);
    end;
    sql.append('WHERE ');
    whereClauses.buildSQL(sql, parameters, indent);
  end;

  if (groupBys.Count > 0) then begin
    if not newLine then begin
      sql.append(#13#10);
      sql.append(indent);
    end;
    sql.append('GROUP BY ');
    groupBys.buildSQL(sql, parameters, indent);
  end;

  if (havingClauses.Count > 0) then begin
    if not newLine then begin
      sql.append(#13#10);
      sql.append(indent);
    end;
    sql.append('HAVING ');
    havingClauses.buildSQL(sql, parameters, indent);
  end;

  if (orderBys.Count > 0) then begin
    if not newLine then begin
      sql.append(#13#10);
      sql.append(indent);
    end;
    sql.append('ORDER BY ');
    orderBys.buildSQL(sql, parameters, indent);
  end;
end;

function TSQLSelectFactory.prepareQuery(Connection : TPRADOConnection;
  ExecuteOptions : TExecuteOptions = [];
  Open : WordBool = true) : TPRADOQuery;
Var
  Parameters : TParameterList;
begin
  Result := TPRADOQuery.Create(nil);
  Parameters := TParameterList.Create;
  try try
    Result.Connection := Connection;
    Result.SQL.Text := buildSQL(Parameters);
    Result.ExecuteOptions := ExecuteOptions;
    if (Parameters.Count > 0) then
      Parameters.CopyTo(Result.Parameters);

    if (Open) then
      Result.Open;
  except
    SafeFree(Result);
    Result := nil;
    raise;
  end;
  finally
    SafeFree(Parameters);
  end;
end;


{ TSQLCallFactory }
constructor TSQLCallFactory.Create(ProcedureName: String; hasReturnValue : Boolean = false);
begin
  inherited Create;

  fProcedureName := ProcedureName;
  fHasReturnValue := hasReturnValue;
end;


function TSQLCallFactory.AddOutputParameter(DataType : TDataType) : TParameteredElement;
begin
  Self.Parameters.CreateParameter('', DataType, pdOutput);
  Result := Self;
end;

procedure TSQLCallFactory.buildSQL(sql: TStringBuffer;  parameters: TParameterList; indent: String);
Var
   i : Integer;
begin
  sql.append(indent);
  sql.append(indent);
  sql.append('{');
  if (HasReturnValue) then begin
    sql.append('? = ');
    parameters.CreateParameter(0, ftInteger, pdReturnValue);
  end;
  sql.append('CALL ');
  sql.append(ProcedureName);

  if (Self.Parameters.Count > 0) then begin
    sql.append(' ( ?');
    for i := 1 to Parameters.Count - 1 do
      sql.append(', ?');

    sql.append(')');
  end;
  sql.append('}');

  inherited buildSQL(sql, parameters, indent);
end;

function TSQLCallFactory.prepareCALL(Connection : TPRADOConnection; ExecuteOptions : TExecuteOptions = []; Execute : WordBool = true) : TPRADOStoredProc;
Var
  Parameters : TParameterList;
begin
  Result := TPRADOStoredProc.Create(nil);
  Parameters := TParameterList.Create;
  try try

    Result.Connection := Connection;
    Result.ProcedureName := Self.ProcedureName;
    Result.ExecuteOptions := ExecuteOptions;
    Self.buildSQL(parameters);
    if (Parameters.Count > 0) then
      Parameters.copyTo(Result.Parameters);
    Result.Prepared := True;

    if (Execute) then
      Result.ExecProc;
  except
    SafeFree(Result);
    Result := nil;
    raise;
  end;
  finally
    SafeFree(Parameters);
  end;
end;

//procedure TTestSQLCall.testCall;
//Var
//  conn : TPRADOConnection;
//  call : TSQLCallFactory;
//  proc : TPRADOStoredProc;
//  i : Integer;
//begin
//  proc := nil;
//  call := TSQLCallFactory.Create('GetNextSequence', True);
//  conn := TPRADOConnection.Create(nil);
//  try
//    conn.ConnectionString := ConnectString;
//    conn.Open;
//
//    call.addParameter('ADDRESS');
//    call.addOutputParameter(ftString);
//    proc := call.prepareCALL(conn);
//
//    ShowMessage('Parameter Count: ' + IntToStr(proc.Parameters.Count));
//    for i := 0 to proc.Parameters.Count - 1 do
//      ShowMessage(IntToStr(i) + ': ' + VarAsString(proc.Parameters[i].Value));
//
//    if (Proc.Active) then
//      ShowMessage('Record Count: ' + IntToStr(proc.RecordCount));
//  finally
//    SafeFree(call);
//    SafeFree(conn);
//    Safefree(proc);
//  end;
//end;

function TSQLCallFactory.Execute(Connection : TPRADOConnection;  ExecuteOptions : TExecuteOptions = [];
                      Execute : WordBool = true) : integer;
begin
  Result := 0;
end;


{ TInsertFieldDef }

constructor TInsertFieldDef.Create(fieldName: String;
  literalValue: Variant);
begin
  inherited Create(fieldName);
  setLiteralValue(literalValue);
end;

constructor TInsertFieldDef.Create(fieldName: String);
begin
  Create(fieldName, VarNull);
end;

function TInsertFieldDef.getLiteralValue: Variant;
begin
  Result := fLiteralValue.Value;
end;

procedure TInsertFieldDef.SetLiteralValue(Value: Variant);
begin
  fLiteralValue.Value := Value;
  fLiteralValue.DataType := VarTypeToDataType(VarType(Value));
end;

function TInsertFieldDef.GetIsLiteral: WordBool;
begin
  Result := (fLiteralValue <> nil);
end;

function TInsertFieldDef.GetColumnName: String;
begin
  Result := fColumnName;
end;

procedure TInsertFieldDef.SetColumnName(Value: String);
begin
  fColumnName := Value;
end;

function TInsertFieldDef.GetIsParameter: WordBool;
begin
  Result := Self.Parameters.Count > 0;
end;

function VarToLiteralValue(Value : Variant) : String;
begin
    case VarType(Value) of
      varSmallint,
      varInteger ,
      varSingle,
      varDouble,
      varCurrency,
      varShortInt,
      varByte,
      varWord,
      varLongWord,
      varInt64 :
        Result := VarToStr(Value);

      varDate:
        Result := '''' + FormatDateTime('mm/dd/yyyy hh:nn:ss', Value) + '''';

      varBoolean:
        if (Value) then
          Result := 'TRUE'
        else
          Result := 'FALSE';

      varOleStr,
      varStrArg,
      varString:
        Result := '''' + StringReplace(Value, '''', '''''', [rfReplaceAll]) + '''';

      else
        //  varUnknown :
        //  varVariant :
        //  varDispatch:
        //  varError :
        //  varEmpty:
        //  varNull:
        //  varAny :
    end;
end;

procedure TInsertFieldDef.BuildInsertValue(sql: TStringBuffer;  parameters: TParameterList);
begin
  if (IsParameter) then begin
    parameters.addParameter(Self.Parameters[0]);
    sql.append('?');
  end
  else if (isLiteral) then
    sql.append(VarToLiteralValue(literalValue))
  else
    raise ESQLFactoryException.Create('No insert value defined for ' + ColumnExpression);
end;

procedure TInsertFieldDef.buildSQL(sql: TStringBuffer;
  parameters: TParameterList; indent: String);
begin
  // We don't want to call inherited cause we don't want a tableAlias and
  //  we don't want to add the parameters at this time.
  // NO: inherited buildSQL(sql, new ArrayList(), indent);
  sql.append(ColumnExpression);

end;

class function TInsertFieldDef.BuildValuesList(sql: TStringBuffer;
  columns: TCustomFieldList; parameters: TParameterList; Indent: String) : Boolean;
Var
  i : Integer;
begin
    Result := false;
    if (columns.Count > 0) then begin
      if (   TInsertFieldDef(columns[0]).isParameter
          or TInsertFieldDef(columns[0]).isLiteral) then
      begin
         Result := true;
         sql.append('VALUES (');
         TInsertFieldDef(columns[0]).buildInsertValue(sql, parameters);
         for i := 1 to columns.Count - 1 do begin
           sql.append(', ');
           TInsertFieldDef(columns[i]).buildInsertValue(sql, parameters);
         end;
         sql.append(')');
      end
    end;
end;

{ TInsertFieldList }
constructor TInsertFieldList.Create;
begin
  inherited Create;
  Sorted := False;
  ControlLife := True;
  CaselessKeys := True;
end;

function TInsertFieldList.AddColumn(Column: TInsertFieldDef): TInsertFieldDef;
begin
  _AddItem(Column.ColumnName, Column);
  Result := Column;
end;

function TInsertFieldList.InsertColumn(Idx: Integer;
  Column: TInsertFieldDef): TInsertFieldDef;
begin
  _AddItem(Idx, Column.columnName, Column);
  Result := Column;
end;

function TInsertFieldList.GetColumn(Key: Variant): TInsertFieldDef;
begin
  Result := TInsertFieldDef(_GetItem(Key));
end;

{ TSQLInsertFactory }

constructor TSQLInsertFactory.Create(tableExpression, tableAlias: String);
begin
  Create('', tableExpression, tableAlias);

end;

constructor TSQLInsertFactory.Create(tableSchema, tableExpression,
  tableAlias: String);
begin
  inherited Create;
  setIntoTable(tableSchema, tableExpression, tableAlias);
end;

destructor TSQLInsertFactory.Destroy;
begin
  SafeFree(fColumns);

  inherited;
end;

function TSQLInsertFactory.GetIntoTable: TTableDef;
begin
  if (fIntoTable = nil) then begin
    fIntoTable := TTableDef.Create;
  end;

  Result := fIntoTable;
end;

function TSQLInsertFactory.setIntoTable(tableExpression : String; tableAlias : String = '') : TTableDef;
begin
  Result := setIntoTable('', tableExpression, tableAlias);
end;

function TSQLInsertFactory.setIntoTable(tableSchema, tableExpression, tableAlias: String) : TTableDef;
begin
  if (fIntoTable <> nil) then
    SafeFree(fIntoTable);

  fIntoTable := TTableDef.Create(tableSchema, tableExpression, tableAlias);
  Result := fIntoTable;
end;

function TSQLInsertFactory.GetColumns: TInsertFieldList;
begin
  if (fColumns = nil) then
    fColumns := TInsertFieldList.Create;

  Result := fColumns;
end;

function TSQLInsertFactory.addColumn(columnName: String): TInsertFieldDef;
begin
  Result := insertColumn(columns.Count, columnName);
end;

function TSQLInsertFactory.addColumn(columnName: String; literalValue : OleVariant): TInsertFieldDef;
begin
  Result := addColumn(columnName );
  Result.LiteralValue := literalValue;
end;

procedure TSQLInsertFactory.addColumns(columnInfo: array of string);
begin
  insertColumns(columns.Count, columnInfo);
end;

function TSQLInsertFactory.insertColumn(columnPos: Integer;
  columnName: String): TInsertFieldDef;
begin
  Result := TInsertFieldDef.Create;
  Result.ColumnName := columnName;
  columns.InsertColumn(columnPos, Result);
end;

procedure TSQLInsertFactory.insertColumns(columnPos: Integer;
  columnInfo: array of string);
Var
  i, p : Integer;
  tmpColumnExpression, tmpColumnName : String;
begin
  for i := High(columnInfo) downto 0 do begin
    p := 1;
//    tmpColumnExpression := ParseNext(p, columnInfo[i], ', ', '"[]');
    tmpColumnName := ParseNext(p, columnInfo[i], ', ', '"[]');
    insertColumn(columnPos, tmpColumnName);
  end;
end;


function TSQLInsertFactory.SubSelectParameters: TParameterList;
begin
  if (fSubSelectParameters = nil) then
    fSubSelectParameters := TParameterList.Create;

  Result := fSubSelectParameters;
end;

function TSQLInsertFactory.GetfromTable: TTableDef;
begin
  if (fFromTable = nil) then begin
    fFromTable := TTableDef.Create;
  end;

  Result := fFromTable;
end;

function TSQLInsertFactory.setFromTable(tableExpression : String; tableAlias : String = '') : TTableDef;
begin
  Result := setFromTable('', tableExpression, tableAlias);
end;

function TSQLInsertFactory.setFromTable(tableSchema, tableExpression, tableAlias: String) : TTableDef;
begin
  subSelectParameters.clear;
  if (fFromTable <> nil) then
    SafeFree(fFromTable);

  fFromTable := TTableDef.Create(tableSchema, tableExpression, tableAlias);
  Result := fFromTable;
end;

function TSQLInsertFactory.setFromTable(subSelect: TSQLSelectFactory; tableAlias: String) : TTableDef;
Var
  parms : TParameterList;
  sql : TStringBuffer;
begin
  parms := TParameterList.Create;
  sql := TStringBuffer.Create;
  try
    sql.append('(');
    subSelect.buildSQL(sql, parms, STD_INDENT);
    sql.append(')');

    Result := setFromTable(sql.toString, tableAlias);
    subSelectParameters.addParameters(parms);
  finally
    SafeFree(parms);
    SafeFree(sql);
  end;
end;



initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLFactoryCall.pas,v $', '$Revision: 1.8 $', '$Date: 2011/12/02 19:59:03 $');
{$ENDIF}
end.


