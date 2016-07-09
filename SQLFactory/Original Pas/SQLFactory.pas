{****************************************************************************
  SQL Factory Consolidation Unit
  &nbsp;
  This unit simply consolidates the types defined in the separate
  SQLFactory(xxx) units to allow the developer to use only one unit and
  get the entire library.
  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2013/03/01 19:01:06 $
  @group Shared.SQLFactory
  @see SQLFactoryBase
  @see SQLFactorySelect
  @see SQLFactoryModify
  @version $Id: SQLFactory.pas,v 1.11 2013/03/01 19:01:06 jchaney Exp $
  @version
******************************************************************************}

unit SQLFactory;

interface

uses Classes, CommonStringLib, TypedList, SysUtils, ADODB, PRADODB,
  SQLFactoryBase, SQLFactorySelect, SQLFactoryModify;

{$TYPEINFO ON}
type
  ESQLFactoryException = SQLFactoryBase.ESQLFactoryException;
  TParameter = SQLFactoryBase.TParameter;
  TParameterList = SQLFactoryBase.TParameterList;
  ISQLElement = SQLFactoryBase.ISQLElement;
  TSQLElementItem = SQLFactoryBase.TSQLElementItem;
  TSQLElementList = SQLFactoryBase.TSQLElementList;
  TSQLElementParent = SQLFactoryBase.TSQLElementParent;
  TParameteredElement = SQLFactoryBase.TParameteredElement;

  TTableDef = SQLFactoryBase.TTable;
  TColumn = SQLFactoryBase.TColumn;
  TCustomColumnList = SQLFactoryBase.TCustomColumnList;
  TColumnList = SQLFactoryBase.TColumnList;

  TCondition = SQLFactoryBase.TCondition;
  TConditionClass = SQLFactoryBase.TConditionClass;
  TConditionLinkOperator = SQLFactoryBase.TConditionLinkOperator;
  TConditionList = SQLFactoryBase.TConditionList;
  TSimpleCondition = SQLFactoryBase.TSimpleCondition;
  TConditionGroup = SQLFactoryBase.TConditionGroup;
  TINListCondition = SQLFactoryBase.TINListCondition;
  TINSelectCondition = SQLFactorySelect.TINSelectCondition;

  TFromTable = SQLFactorySelect.TFromTable;

  TFieldValueDef = SQLFactoryBase.TFieldValueDef;
  TFieldValueList = SQLFactoryBase.TFieldValueList;

  TOrderByColumn = SQLFactorySelect.TOrderByColumn;
  TGroupByColumn = SQLFactorySelect.TGroupByColumn;
  TSelectColumn = SQLFactorySelect.TSelectColumn;
  TSelectColumnList = SQLFactorySelect.TSelectColumnList;

  TJoinTable = SQLFactorySelect.TJoinTable;
  TJoinTableList = SQLFactorySelect.TJoinTableList;
  TJoinType = SQLFactorySelect.TJoinType;

  TSQLSelectFactory = SQLFactorySelect.TSQLSelectFactory;

//  TSQLCallFactory = SQLFactoryCall.TSQLCallFactory;

  TSQLInsertFactory = SQLFactoryModify.TSQLInsertFactory;
  TSQLUpdateFactory = SQLFactoryModify.TSQLUpdateFactory;
  TSQLDeleteFactory = SQLFactoryModify.TSQLDeleteFactory;
  TSQLInsertOrUpdateFactory = SQLFactoryModify.TSQLInsertOrUpdateFactory;

const
  jtLeftJoin = SQLFactorySelect.jtLeftJoin;
  jtJoin = SQLFactorySelect.jtJoin;
  jtRightJoin = SQLFactorySelect.jtRightJoin;
  jtFullJoin = SQLFactorySelect.jtFullJoin;
  loAND = SQLFactoryBase.loAND;
  loOR = SQLFactoryBase.loOR;

function LinkOperatorToCode(link : TConditionLinkOperator) : String;
function CodeToLinkOperator(code : String) : TConditionLinkOperator;
function StringToJoinType(Code : String) : TJoinType;
function JoinTypeToString(JoinType : TJoinType) : String;

implementation
uses
   UnitVersion;

function LinkOperatorToCode(link : TConditionLinkOperator) : String;
begin
  Result := SQLFactoryBase.LinkOperatorToCode(link);
end;

function CodeToLinkOperator(code : String) : TConditionLinkOperator;
begin
  Result := SQLFactoryBase.CodeToLinkOperator(code);
end;

function JoinTypeToString(JoinType : TJoinType) : String;
begin
  case JoinType of
  jtJoin: Result := 'jtJoin';
  jtLeftJoin: Result := 'jtLeftJoin';
  jtRightJoin: Result := 'jtRightJoin';
  jtFullJoin: Result := 'jtFullJoin';
  else Result := 'Unknown TJoinType(' + IntToStr(Ord(JoinType)) + ')';
  end;
end;

function StringToJoinType(Code : String) : TJoinType;
begin
  if StringMatch(Code, 'jtLeftJoin') or StringMatch(Code, 'LEFT')  or StringMatch(Code, 'LEFT OUTER') then
    Result := jtLeftJoin
  else if StringMatch(Code, 'jtRightJoin') or StringMatch(Code, 'RIGHT') then
    Result := jtRightJoin
  else if StringMatch(Code, 'jtFullJoin') or StringMatch(Code, 'FULL') then
    Result := jtFullJoin
  else //if StringMatch(Code, 'jtJoin') then
    Result := jtJoin;
end;


initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLFactory.pas,v $', '$Revision: 1.11 $', '$Date: 2013/03/01 19:01:06 $');
{$ENDIF}
end.

