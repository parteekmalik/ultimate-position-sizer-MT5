//+------------------------------------------------------------------+
//|                                               Position Sizer.mq5 |
//|                                  Copyright © 2023, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-expert-advisors/Position-Sizer/"
#property version   "3.03"
string    Version = "3.03";

#property description "Calculates risk-based position size for your account."
#property description "Allows trade execution based the calculation results.\r\n"
#property description "WARNING: No warranty. This EA is offered \"as is\". Use at your own risk.\r\n"
#property description "Note: Pressing Shift+T will open a trade."

#include "Position Sizer.mqh";
#include "Position Sizer Trading.mqh";

// Default values for settings:
double EntryLevel = 0;
double StopLossLevel = 0;
double TakeProfitLevel = 0;
double StopPriceLevel = 0;
string PanelCaption = "";
string PanelCaptionBase = "";

input group "Compactness"
input bool ShowLineLabels = true; // ShowLineLabels: Show point distance for TP/SL near lines?
input bool ShowAdditionalSLLabel = false; // ShowAdditionalSLLabel: Show SL $/% label?
input bool ShowAdditionalTPLabel = false; // ShowAdditionalTPLabel: Show TP $/% + R/R label?
input bool DrawTextAsBackground = false; // DrawTextAsBackground: Draw label objects as background?
input bool HideAccSize = false; // HideAccSize: Hide account size?
input bool ShowPointValue = false; // ShowPointValue: Show point value?
input bool ShowMaxPSButton = false; // ShowMaxPSButton: Show Max Position Size button?
input bool StartPanelMinimized = false; // StartPanelMinimized: Start the panel minimized?
input bool ShowATROptions = false; // ShowATROptions: If true, SL and TP can be set via ATR.
input group "Fonts"
input color sl_label_font_color = clrBlack; // SL Label Color
input color tp_label_font_color = clrBlack; // TP Label Color
input color sp_label_font_color = clrPurple; // Stop Price Label Color
input uint font_size = 13; // Labels Font Size
input string font_face = "Courier"; // Labels Font Face
input group "Lines"
input color entry_line_color = clrBlue; // Entry Line Color
input color stoploss_line_color = clrLime; // Stop-Loss Line Color
input color takeprofit_line_color = clrYellow; // Take-Profit Line Color
input color stopprice_line_color = clrPurple; // Stop Price Line Color
input ENUM_LINE_STYLE entry_line_style = STYLE_SOLID; // Entry Line Style
input ENUM_LINE_STYLE stoploss_line_style = STYLE_SOLID; // Stop-Loss Line Style
input ENUM_LINE_STYLE takeprofit_line_style = STYLE_SOLID; // Take-Profit Line Style
input ENUM_LINE_STYLE stopprice_line_style = STYLE_DOT; // Stop Price Line Style
input uint entry_line_width = 1; // Entry Line Width
input uint stoploss_line_width = 1; // Stop-Loss Line Width
input uint takeprofit_line_width = 1; // Take-Profit Line Width
input uint stopprice_line_width = 1; // Stop Price Line Width
input group "Defaults"
input TRADE_DIRECTION DefaultTradeDirection = Long; // TradeDirection: Default trade direction.
input int DefaultSL = 0; // SL: Default stop-loss value, in points.
input int DefaultTP = 0; // TP: Default take-profit value, in points.
input int DefaultTakeProfitsNumber = 1; // TakeProfitsNumber: More than 1 target to split trades.
input ENTRY_TYPE DefaultEntryType = Instant; // EntryType: Instant, Pending, or StopLimit.
input bool DefaultShowLines = true; // ShowLines: Show the lines by default?
input bool DefaultLinesSelected = true; // LinesSelected: SL/TP (Entry in Pending) lines selected.
input int DefaultATRPeriod = 14; // ATRPeriod: Default ATR period.
input double DefaultATRMultiplierSL = 0; // ATRMultiplierSL: Default ATR multiplier for SL.
input double DefaultATRMultiplierTP = 0; // ATRMultiplierTP: Default ATR multiplier for TP.
input ENUM_TIMEFRAMES DefaultATRTimeframe = PERIOD_CURRENT; // ATRTimeframe: Default timeframe for ATR.
input bool DefaultSpreadAdjustmentSL = false; // SpreadAdjustmentSL: Adjust SL by Spread value in ATR mode.
input bool DefaultSpreadAdjustmentTP = false; // SpreadAdjustmentTP: Adjust TP by Spread value in ATR mode.
input double DefaultCommission = 0; // Commission: Default one-way commission per 1 lot.
input COMMISSION_TYPE DefaultCommissionType = COMMISSION_CURRENCY; // CommossionType: Default commission type.
input ACCOUNT_BUTTON DefaultAccountButton = Balance; // AccountButton: Balance/Equity/Balance-CPR
input double DefaultRisk = 1; // Risk: Initial risk tolerance in percentage points
input double DefaultMoneyRisk = 0; // MoneyRisk: If > 0, money risk tolerance in currency.
input double DefaultPositionSize = 0; // PositionSize: If > 0, position size in lots.
input bool DefaultCountPendingOrders = false; // CountPendingOrders: Count pending orders for portfolio risk.
input bool DefaultIgnoreOrdersWithoutSL = false; // IgnoreOrdersWithoutSL: Ignore orders w/o SL in portfolio risk.
input bool DefaultIgnoreOrdersWithoutTP = false; // IgnoreOrdersWithoutTP: Ignore orders w/o TP in portfolio risk.
input bool DefaultIgnoreOtherSymbols = false; // IgnoreOtherSymbols: Ignore other symbols' orders in portfolio risk.
double DefaultCustomLeverage = 0; // CustomLeverage: Default custom leverage for Margin tab.
input int DefaultMagicNumber = 2022052714; // MagicNumber: Default magic number for Trading tab.
input string DefaultCommentary = ""; // Commentary: Default order comment for Trading tab.
input bool DefaultCommentAutoSuffix = false; // AutoSuffix: Automatic suffix for order commentary in Trading tab.
input bool DefaultDisableTradingWhenLinesAreHidden = false; // DisableTradingWhenLinesAreHidden: for Trading tab.
input int DefaultMaxSlippage = 0; // MaxSlippage: Maximum slippage for Trading tab.
input int DefaultMaxSpread = 0; // MaxSpread: Maximum spread for Trading tab.
input int DefaultMaxEntrySLDistance = 0; // MaxEntrySLDistance: Maximum entry/SL distance for Trading tab.
input int DefaultMinEntrySLDistance = 0; // MinEntrySLDistance: Minimum entry/SL distance for Trading tab.
input double DefaultMaxPositionSize = 0; // MaxPositionSize: Maximum position size for Trading tab.
input bool DefaultSubtractOPV = false; // SubtractOPV: Subtract open positions volume (Trading tab).
input bool DefaultSubtractPOV = false; // SubtractPOV: Subtract pending orders volume (Trading tab).
input bool DefaultDoNotApplyStopLoss = false; // DoNotApplyStopLoss: Don't apply SL for Trading tab.
input bool DefaultDoNotApplyTakeProfit = false; // DoNotApplyTakeProfit: Don't apply TP for Trading tab.
input bool DefaultAskForConfirmation = true; // AskForConfirmation: Ask for confirmation for Trading tab.
input int DefaultPanelPositionX = 0; // PanelPositionX: Panel's X coordinate.
input int DefaultPanelPositionY = 15; // PanelPositionY: Panel's Y coordinate.
input ENUM_BASE_CORNER DefaultPanelPositionCorner = CORNER_LEFT_UPPER; // PanelPositionCorner: Panel's corner.
input bool DefaultTPLockedOnSL = false; // TPLockedOnSL: Lock TP to (multiplied) SL distance.
input int DefaultTrailingStop = 0; // TrailingStop: For the Trading tab.
input int DefaultBreakEven = 0; // BreakEven: For the Trading tab.
input int DefaultMaxNumberOfTrades = 0; // MaxNumberOfTrades: For the Trading tab. 0 - no limit.
input double DefaultMaxTotalRisk = 0; // MaxTotalRisk: For the Trading tab. 0 - no limit.
input bool DefaultAllSymbols = true; // AllSymbols: For Trading tab, true - count trades in all symbols.
input group "Keyboard shortcuts"
input string ____ = "Case-insensitive hotkey. Supports Ctrl, Shift.";
input string TradeHotKey = "Shift+T"; // TradeHotKey: Execute a trade.
input string SwitchOrderTypeHotKey = "O"; // SwitchOrderTypeHotKey: Switch order type.
input string SwitchEntryDirectionHotKey = "TAB"; // SwitchEntryDirectionHotKey: Switch entry direction.
input string SwitchHideShowLinesHotKey = "H"; // SwitchHideShowLinesHotKey: Switch Hide/Show lines.
input group "Miscellaneous"
input double TP_Multiplier = 1; // TP Multiplier for SL value, appears in Take-profit button.
input bool UseCommissionToSetTPDistance = false; // UseCommissionToSetTPDistance: For TP button.
input SHOW_SPREAD ShowSpread = No; // ShowSpread: Show current spread in points or as an SL ratio.
input double AdditionalFunds = 0; // AdditionalFunds: Added to account balance for risk calculation.
input double CustomBalance = 0; // CustomBalance: Overrides AdditionalFunds value.
input bool SLDistanceInPoints = false; // SLDistanceInPoints: SL distance in points instead of a level.
input bool TPDistanceInPoints = false; // TPDistanceInPoints: TP distance in points instead of a level.
input CANDLE_NUMBER ATRCandle = Current_Candle; // ATRCandle: Candle to get ATR value from.
input bool CalculateUnadjustedPositionSize = false; // CalculateUnadjustedPositionSize: Ignore broker's restrictions.
input bool SurpassBrokerMaxPositionSize = false; // Surpass Broker Max Position Size with multiple trades.
input bool RoundDown = true; // RoundDown: Position size and potential reward are rounded down.
input double QuickRisk1 = 0; // QuickRisk1: First quick risk button, in percentage points.
input double QuickRisk2 = 0; // QuickRisk2: Second quick risk button, in percentage points.
input string ObjectPrefix = "PS_"; // ObjectPrefix: To prevent confusion with other indicators/EAs.
input SYMBOL_CHART_CHANGE_REACTION SymbolChange = SYMBOL_CHART_CHANGE_EACH_OWN; // SymbolChange: What to do with the panel on chart symbol change?
input bool DisableStopLimit = false; // DisableStopLimit: If true, Stop Limit will be skipped.
input string TradeSymbol = ""; // TradeSymbol: If non-empty, this symbol will be traded.
input bool DisableTradingSounds = false; // DisableTradingSounds: If true, no sound for trading actions.
input bool IgnoreMarketExecutionMode = true; // IgnoreMarketExecutionMode: If true, ignore Market execution.
input bool MarketModeApplySLTPAfterAllTradesExecuted = false; // Market Mode - Apply SL/TP After All Trades Executed

CPositionSizeCalculator* ExtDialog;

// Global variables:
bool Dont_Move_the_Panel_to_Default_Corner_X_Y = true;
uint LastRecalculationTime = 0;
bool StopLossLineIsBeingMoved = false;
bool TakeProfitLineIsBeingMoved = false;
uchar MainKey_TradeHotKey = 0, MainKey_SwitchOrderTypeHotKey = 0, MainKey_SwitchEntryDirectionHotKey = 0, MainKey_SwitchHideShowLinesHotKey = 0;
bool CtrlRequired_TradeHotKey = false, CtrlRequired_SwitchOrderTypeHotKey = false, CtrlRequired_SwitchEntryDirectionHotKey = false, CtrlRequired_SwitchHideShowLinesHotKey = false;
bool ShiftRequired_TradeHotKey = false, ShiftRequired_SwitchOrderTypeHotKey = false, ShiftRequired_SwitchEntryDirectionHotKey = false, ShiftRequired_SwitchHideShowLinesHotKey = false;
bool AdditionalTPLineMoved = false;
int DeinitializationReason = -1;
string OldSymbol = "";
int OldTakeProfitsNumber = -1;
string SymbolForTrading;

int OnInit()
{
    TickSize = -1;

    if (DeinitializationReason != REASON_CHARTCHANGE) ExtDialog = new CPositionSizeCalculator; // Create the panel only if it is not a symbol/timeframe change.
    else OldTakeProfitsNumber = sets.TakeProfitsNumber; // Will be used to resize the panel if needed when switching symbols in some modes.

    MathSrand(GetTickCount() + 293029); // Used by CreateInstanceId() in Dialog.mqh (standard library). Keep the second number unique across other panel indicators/EAs.
    
    Dont_Move_the_Panel_to_Default_Corner_X_Y = true;
    
    PanelCaptionBase = "Position Sizer (ver. " + Version + ")";

    // Symbol changed.
    if ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol))
    {
        ObjectsDeleteAll(0, ObjectPrefix); // All lines should be deleted, so that they could be recreated at new sets. values.
        if (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN)
        {
            ExtDialog.SaveSettingsOnDisk(OldSymbol); // Save old symbol's settings.
        }
        ExtDialog.UpdateFileName(); // Update the filename.

        // Reset everything.
        OutputPointValue = ""; OutputSwapsType = "Unknown"; SwapsTripleDay = "?";
        OutputSwapsDailyLongLot = "?"; OutputSwapsDailyShortLot = "?"; OutputSwapsDailyLongPS = "?"; OutputSwapsDailyShortPS = "?";
        OutputSwapsYearlyLongLot = "?"; OutputSwapsYearlyShortLot = "?"; OutputSwapsYearlyLongPS = "?"; OutputSwapsYearlyShortPS = "?";
        OutputSwapsCurrencyDailyLot = ""; OutputSwapsCurrencyDailyPS = ""; OutputSwapsCurrencyYearlyLot = ""; OutputSwapsCurrencyYearlyPS = "";

        if (SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET)
        {
            // Lines are treated as a part of the panel.
            if (DefaultLinesSelected) LinesSelectedStatus = 1; // Flip lines to selected.
            else LinesSelectedStatus = 2; // Flip lines to unselected.
        }
    }

    // Normal attempt to load settings fails (attempted in not chart change case and in chart case with 'each pair own settings' case
    if ((((DeinitializationReason != REASON_CHARTCHANGE) || ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol) && (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN))) && (!ExtDialog.LoadSettingsFromDisk())) 
    // OR chart change with hard_reset configured and with symbol change.
      || ((DeinitializationReason == REASON_CHARTCHANGE) && (SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET) && (OldSymbol != _Symbol)))
    {
        sets.TradeDirection = DefaultTradeDirection;
        sets.EntryLevel = EntryLevel;
        sets.StopLossLevel = StopLossLevel;
        sets.TakeProfitLevel = TakeProfitLevel; // Optional
        sets.TakeProfitsNumber = DefaultTakeProfitsNumber;
        if (sets.TakeProfitsNumber < 1) sets.TakeProfitsNumber = 1; // At least one TP.
        ArrayResize(sets.TP, sets.TakeProfitsNumber);
        ArrayResize(sets.TPShare, sets.TakeProfitsNumber);
        ArrayInitialize(sets.TP, 0);
        ArrayInitialize(sets.TPShare, 100 / sets.TakeProfitsNumber);
        ArrayResize(sets.WasSelectedAdditionalTakeProfitLine, sets.TakeProfitsNumber - 1); // -1 because the flag for the main TP is saved elsewhere.
        sets.StopPriceLevel = StopPriceLevel; // Optional
        sets.ATRPeriod = DefaultATRPeriod;
        sets.ATRMultiplierSL = DefaultATRMultiplierSL;
        sets.ATRMultiplierTP = DefaultATRMultiplierTP;
        sets.ATRTimeframe = DefaultATRTimeframe;
        sets.EntryType = DefaultEntryType; // If Instant, Entry level will be updated to current Ask/Bid price automatically; if Pending, Entry level will remain intact and StopLevel warning will be issued if needed.
        sets.Risk = DefaultRisk; // Risk tolerance in percentage points
        sets.MoneyRisk = DefaultMoneyRisk; // Risk tolerance in account currency
        if (DefaultMoneyRisk > 0) sets.UseMoneyInsteadOfPercentage = true;
        else sets.UseMoneyInsteadOfPercentage = false;
        if (DefaultPositionSize > 0)
        {
            sets.RiskFromPositionSize = true;
            sets.PositionSize = DefaultPositionSize;
            OutputPositionSize = DefaultPositionSize;
        }
        else sets.RiskFromPositionSize = false;
        sets.CommissionPerLot = DefaultCommission; // Commission charged per lot (one side) in account currency or %.
        sets.CommissionType = DefaultCommissionType;
        sets.CustomBalance = CustomBalance;
        sets.RiskFromPositionSize = false;
        sets.AccountButton = DefaultAccountButton;
        sets.CountPendingOrders = DefaultCountPendingOrders; // If true, portfolio risk calculation will also involve pending orders.
        sets.IgnoreOrdersWithoutSL = DefaultIgnoreOrdersWithoutSL; // If true, portfolio risk calculation will skip orders without stop-loss.
        sets.IgnoreOrdersWithoutTP = DefaultIgnoreOrdersWithoutTP; // If true, portfolio risk calculation will skip orders without take-profit.
        sets.IgnoreOtherSymbols = DefaultIgnoreOtherSymbols; // If true, portfolio risk calculation will skip orders in other symbols.
        sets.HideAccSize = HideAccSize; // If true, account size line will not be shown.
        sets.ShowLines = DefaultShowLines;
        sets.SelectedTab = MainTab;
        sets.CustomLeverage = DefaultCustomLeverage;
        sets.MagicNumber = DefaultMagicNumber;
        sets.Commentary = DefaultCommentary;
        sets.CommentAutoSuffix = DefaultCommentAutoSuffix;
        sets.DisableTradingWhenLinesAreHidden = DefaultDisableTradingWhenLinesAreHidden;
        if (sets.TakeProfitsNumber > 1)
        {
            for (int i = 0; i < sets.TakeProfitsNumber; i++)
            {
                sets.TP[i] = TakeProfitLevel;
                sets.TPShare[i] = 100 / sets.TakeProfitsNumber;
            }
        }
        sets.MaxSlippage = DefaultMaxSlippage;
        sets.MaxSpread = DefaultMaxSpread;
        sets.MaxEntrySLDistance = DefaultMaxEntrySLDistance;
        sets.MinEntrySLDistance = DefaultMinEntrySLDistance;
        sets.MaxPositionSize = DefaultMaxPositionSize;
        sets.StopLoss = 0;
        sets.TakeProfit = 0;
        sets.SubtractPendingOrders = DefaultSubtractPOV;
        sets.SubtractPositions = DefaultSubtractOPV;
        sets.DoNotApplyStopLoss = DefaultDoNotApplyStopLoss;
        sets.DoNotApplyTakeProfit = DefaultDoNotApplyTakeProfit;
        sets.AskForConfirmation = DefaultAskForConfirmation;
        sets.WasSelectedEntryLine = false;
        sets.WasSelectedStopLossLine  = false;
        sets.WasSelectedTakeProfitLine = false;
        sets.WasSelectedStopPriceLine = false;
        sets.TPLockedOnSL = DefaultTPLockedOnSL;
        sets.TrailingStopPoints = DefaultTrailingStop;
        sets.BreakEvenPoints = DefaultBreakEven;
        sets.MaxNumberOfTrades = DefaultMaxNumberOfTrades;
        sets.MaxTotalRisk = DefaultMaxTotalRisk;
        sets.AllSymbols = DefaultAllSymbols;
        // Because it is the first load:
        Dont_Move_the_Panel_to_Default_Corner_X_Y = false;
        sets.ShareVolumeMode = Equal;
    }
    if (sets.TakeProfitsNumber < 1) sets.TakeProfitsNumber = 1; // At least one TP.

    if (DeinitializationReason != REASON_CHARTCHANGE)
    {
        if (!ExtDialog.Create(0, "Position Sizer (ver. " + Version + ")", 0, DefaultPanelPositionX, DefaultPanelPositionY)) return INIT_FAILED;
        ExtDialog.Run();

        // No ini file - move the panel according to the inputs.
        if (!FileIsExist(ExtDialog.IniFileName() + ExtDialog.IniFileExt()))
        {
            Dont_Move_the_Panel_to_Default_Corner_X_Y = false;
        }
        ExtDialog.IniFileLoad();

        // If a hotkey is given, break up the string to check for hotkey presses in OnChartEvent().
        if (TradeHotKey != "") DissectHotKeyCombination(TradeHotKey, ShiftRequired_TradeHotKey, CtrlRequired_TradeHotKey, MainKey_TradeHotKey);
        if (SwitchEntryDirectionHotKey != "") DissectHotKeyCombination(SwitchEntryDirectionHotKey, ShiftRequired_SwitchEntryDirectionHotKey, CtrlRequired_SwitchEntryDirectionHotKey, MainKey_SwitchEntryDirectionHotKey);
        if (SwitchOrderTypeHotKey != "") DissectHotKeyCombination(SwitchOrderTypeHotKey, ShiftRequired_SwitchOrderTypeHotKey, CtrlRequired_SwitchOrderTypeHotKey, MainKey_SwitchOrderTypeHotKey);
        if (SwitchHideShowLinesHotKey != "") DissectHotKeyCombination(SwitchHideShowLinesHotKey, ShiftRequired_SwitchHideShowLinesHotKey, CtrlRequired_SwitchHideShowLinesHotKey, MainKey_SwitchHideShowLinesHotKey);
    }
    else if (OldSymbol != _Symbol)
    {
        if (SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET) // Reset Entry, SL, and all TPs if it was a symbol change and a hard reset is required.
        {
            sets.EntryLevel = 0;
            sets.StopLossLevel = 0;
            sets.StopLoss = 0;
            sets.TakeProfitLevel = 0;
            sets.TakeProfit = 0;
            for (int i = 0; i < sets.TakeProfitsNumber; i++)
            {
                sets.TP[i] = 0;
            }
            sets.StopPriceLevel = 0;
            Dont_Move_the_Panel_to_Default_Corner_X_Y = false;
        }
        else if (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN) // Load the INI file if it was a symbol change and a each symbol has its own settings.
        {
            ExtDialog.IniFileLoad();
        }
    }    

    // Avoid re-initialization on timeframe change and on symbol change with the 'keep panel' setting.
    if ((DeinitializationReason != REASON_CHARTCHANGE) || ((DeinitializationReason == REASON_CHARTCHANGE) && (OldSymbol != _Symbol) && ((SymbolChange == SYMBOL_CHART_CHANGE_HARD_RESET) || (SymbolChange == SYMBOL_CHART_CHANGE_EACH_OWN))))
    {
        Initialization();
        if (DeinitializationReason == REASON_CHARTCHANGE) // Do not run if it is not the symbol change because 'CPositionSizeCalculator::Create()' takes care of that in other cases.
        {
            // Remove extra empty space on the panel when going from a panel with more TPs to a panel with fewer TPs.
            if (sets.TakeProfitsNumber < OldTakeProfitsNumber)
            {
                int NewTakeProfitsNumber = sets.TakeProfitsNumber;
                sets.TakeProfitsNumber = OldTakeProfitsNumber; // Used and decremented inside OnClickBtnTakeProfitsNumberRemove().
                while (sets.TakeProfitsNumber > NewTakeProfitsNumber)
                {
                    ExtDialog.OnClickBtnTakeProfitsNumberRemove();
                }
            }
            else
            {
                // Create necessary panel elements if newly loaded symbol has more TPs.
                int NewTakeProfitsNumber = sets.TakeProfitsNumber;
                sets.TakeProfitsNumber = OldTakeProfitsNumber; // It will be increased inside OnClickBtnTakeProfitsNumberAdd().
                while (sets.TakeProfitsNumber < NewTakeProfitsNumber)
                {
                    ExtDialog.OnClickBtnTakeProfitsNumberAdd();
                }
            }
        }
    }
    // Brings panel on top of other objects without actual maximization of the panel.
    ExtDialog.HideShowMaximize();
    if (!Dont_Move_the_Panel_to_Default_Corner_X_Y)
    {
        int new_x = DefaultPanelPositionX, new_y = DefaultPanelPositionY;
        int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
        int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
        int panel_width = ExtDialog.Width();
        int panel_height = ExtDialog.Height();

        // Invert coordinate if necessary.
        if (DefaultPanelPositionCorner == CORNER_LEFT_LOWER)
        {
            new_y = chart_height - panel_height - new_y;
        }
        else if (DefaultPanelPositionCorner == CORNER_RIGHT_UPPER)
        {
            new_x = chart_width - panel_width - new_x;
        }
        else if (DefaultPanelPositionCorner == CORNER_RIGHT_LOWER)
        {
            new_x = chart_width - panel_width - new_x;
            new_y = chart_height - panel_height - new_y;
        }

        ExtDialog.remember_left = new_x;
        ExtDialog.remember_top = new_y;
        ExtDialog.Move(new_x, new_y);
        ExtDialog.FixatePanelPosition(); // Remember the panel's new position for the INI file.
    }

    if ((StartPanelMinimized) && (!ExtDialog.IsMinimized()) && (!Dont_Move_the_Panel_to_Default_Corner_X_Y)) // Minimize only if needs minimization. We check Dont_Move_the_Panel_to_Default_Corner_X_Y to make sure we didn't load an INI-file. An INI-file already contains a more preferred state for the panel.
    {
        // No access to the minmax button, no way to edit the chart height.
        // Dummy variables for passing as references.
        long lparam = 0;
        double dparam = 0;
        string sparam = "";
        // Increasing the height of the panel beyond that of the chart will trigger its minimization.
        ExtDialog.Height((int)ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS) + 1);
        // Call the chart event processing function.
        ExtDialog.ChartEvent(CHARTEVENT_CHART_CHANGE, lparam, dparam, sparam);
    }

    if (!EventSetTimer(1)) Print("Error setting timer: ", GetLastError());

    if (ShowATROptions) ExtDialog.InitATR();

    if (TradeSymbol != "") SymbolForTrading = TradeSymbol;
    else SymbolForTrading = _Symbol;

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    DeinitializationReason = reason; // Remember reason to avoid recreating the panel in the OnInit() if it is not deleted here.
    
    EventKillTimer();

    if (reason == REASON_TEMPLATE) sets.TemplateChanged = true; // Will be used to select lines according to the DefaultLinesSelected input parameter.

    if ((reason == REASON_CLOSE) || (reason == REASON_REMOVE) || (reason == REASON_CHARTCLOSE) || (reason == REASON_PROGRAM))
    {
        ObjectsDeleteAll(0, ObjectPrefix); // Delete all lines if platform was closed.
        if ((reason == REASON_REMOVE) || (reason == REASON_PROGRAM))
        {
            ExtDialog.DeleteSettingsFile();
            if (!FileDelete(ExtDialog.IniFileName() + ExtDialog.IniFileExt())) Print("Failed to delete the PS panel's .ini file: ", GetLastError());
        }
    }
    
    // It is deinitialization due to input parameters change - save current parameters values (that are also changed via panel) to global variables.
    if (reason == REASON_PARAMETERS) GlobalVariableSet("PS-" + IntegerToString(ChartID()) + "-Parameters", 1);

    if ((reason != REASON_CHARTCHANGE) && (reason != REASON_REMOVE) && (reason != REASON_PROGRAM))
    {
        ExtDialog.SaveSettingsOnDisk();
        ExtDialog.IniFileSave();
    } 

    if (reason == REASON_CHARTCHANGE)
    {
        OldSymbol = _Symbol;
    }
    else
    {
        ObjectDelete(0, ObjectPrefix + "StopLossLabel");
        ObjectsDeleteAll(0, ObjectPrefix + "TakeProfitLabel", -1, OBJ_LABEL);
        ObjectDelete(0, ObjectPrefix + "StopPriceLabel");
        ObjectsDeleteAll(0, ObjectPrefix + "TPAdditionalLabel", -1, OBJ_LABEL);
        ObjectDelete(0, ObjectPrefix + "SLAdditionalLabel");
        ExtDialog.Destroy();
        delete ExtDialog;
    }
    
    ChartRedraw();
}

void OnTick()
{
    ExtDialog.RefreshValues();

    if (sets.TrailingStopPoints > 0) DoTrailingStop();
    if (sets.BreakEvenPoints > 0) DoBreakEven();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Mouse move while left mouse button is down.
    if ((id == CHARTEVENT_MOUSE_MOVE) && (((uint)sparam & 1) == 1))
    {
        if ((SLDistanceInPoints) || ((ShowATROptions) && (sets.ATRMultiplierSL > 0)))
        {
            double current_line_price = ObjectGetDouble(ChartID(), ObjectPrefix + "StopLossLine", OBJPROP_PRICE, 0);
            if (current_line_price != tStopLossLevel) StopLossLineIsBeingMoved = true;
            else StopLossLineIsBeingMoved = false;
        }
        if ((TPDistanceInPoints) || ((ShowATROptions) && (sets.ATRMultiplierTP > 0)))
        {
            TakeProfitLineIsBeingMoved = false;
            double current_line_price = ObjectGetDouble(ChartID(), ObjectPrefix + "TakeProfitLine", OBJPROP_PRICE, 0);
            if (current_line_price != tTakeProfitLevel) TakeProfitLineIsBeingMoved = true;
            // Additional take-profits.
            else
            {
                for (int i = 1; i < sets.TakeProfitsNumber; i++) // Will fire only if sets.TakeProfitsNumber > 1.
                {
                    if (sets.TP[i] != 0) // With zero points TP, keep the TP lines at zero level - as with the main TP level.
                    {
                        current_line_price = ObjectGetDouble(ChartID(), ObjectPrefix + "TakeProfitLine" + IntegerToString(i), OBJPROP_PRICE, 0);
                        if (current_line_price != sets.TP[i])
                        {
                            TakeProfitLineIsBeingMoved = true;
                            break;
                        }
                    }
                }
            }
        }
    }

    // Remember the panel's location to have the same location for minimized and maximized states.
    if ((id == CHARTEVENT_CUSTOM + ON_DRAG_END) && (lparam == -1))
    {
        ExtDialog.remember_top = ExtDialog.Top();
        ExtDialog.remember_left = ExtDialog.Left();
    }

    // Catch multiple TP fields.
    if (sets.TakeProfitsNumber > 1)
    {
        if (id == CHARTEVENT_OBJECT_ENDEDIT)
        //if (id == CHARTEVENT_CUSTOM + ON_END_EDIT)
        {
            // Additional take-profit field #N on Main tab.
            if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "AdditionalTPEdits")) == ExtDialog.Name() + "AdditionalTPEdits")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "AdditionalTPEdits"))) - 1;
                ExtDialog.UpdateAdditionalTPEdit(i);
            }
            // Take-profit field #N on Trading tab.
            else if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_EdtTradingTPEdit")) == ExtDialog.Name() + "m_EdtTradingTPEdit")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_EdtTradingTPEdit"))) - 1;
                ExtDialog.UpdateTradingTPEdit(i);
            }
            // Take-profit share field #N on Trading tab.
            else if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "m_EdtTradingTPShareEdit")) == ExtDialog.Name() + "m_EdtTradingTPShareEdit")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "m_EdtTradingTPShareEdit"))) - 1;
                ExtDialog.UpdateTradingTPShareEdit(i);
            }
        }
        else if (id == CHARTEVENT_CUSTOM + ON_CLICK)
        {
            // Additional take-profit increase button #N on Main tab.
            if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "AdditionalTPButtonsIncrease")) == ExtDialog.Name() + "AdditionalTPButtonsIncrease")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "AdditionalTPButtonsIncrease"))) - 1;
                ExtDialog.ProcessAdditionalTPButtonsIncrease(i);
            }
            // Additional take-profit decrease button #N on Main tab.
            else if (StringSubstr(sparam, 0, StringLen(ExtDialog.Name() + "AdditionalTPButtonsDecrease")) == ExtDialog.Name() + "AdditionalTPButtonsDecrease")
            {
                int i = (int)StringToInteger(StringSubstr(sparam, StringLen(ExtDialog.Name() + "AdditionalTPButtonsDecrease"))) - 1;
                ExtDialog.ProcessAdditionalTPButtonsDecrease(i);
            }
            // Because there is a bug that keeps a control's Id() = -1 if it is created after the panel is initialized. So, it cannot be processed with the panel's event processor.
            else if (sparam == ExtDialog.Name() + "m_BtnTakeProfitsNumberRemove")
            {
                ExtDialog.OnClickBtnTakeProfitsNumberRemove();
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTPsInward")
            {
                ExtDialog.OnClickBtnTPsInward();
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTPsOutward")
            {
                ExtDialog.OnClickBtnTPsOutward();
            }
            else if (sparam == ExtDialog.Name() + "m_BtnTradingTPShare")
            {
                ExtDialog.OnClickBtnTradingTPShare();
            }
        }
    }

    if (id == CHARTEVENT_KEYDOWN)
    {
        // Trade direction:
        if ((MainKey_SwitchEntryDirectionHotKey != 0) && (lparam == MainKey_SwitchEntryDirectionHotKey))
        {
            if (((!ShiftRequired_SwitchEntryDirectionHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) < 0)) // Shift
            &&  ((!CtrlRequired_SwitchEntryDirectionHotKey)  || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) < 0))) // Control
            {
                SwitchEntryDirection();
            }
        }
        // Order type:
        else if ((MainKey_SwitchOrderTypeHotKey != 0) && (lparam == MainKey_SwitchOrderTypeHotKey))
        {
            if (((!ShiftRequired_SwitchOrderTypeHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) < 0)) // Shift
            &&  ((!CtrlRequired_SwitchOrderTypeHotKey)  || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) < 0))) // Control
            {
                ExtDialog.OnClickBtnOrderType();
                ChartRedraw();
            }
        }
        // Hide/Show lines:
        else if ((MainKey_SwitchHideShowLinesHotKey != 0) && (lparam == MainKey_SwitchHideShowLinesHotKey))
        {
            if (((!ShiftRequired_SwitchHideShowLinesHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) < 0)) // Shift
            &&  ((!CtrlRequired_SwitchHideShowLinesHotKey)  || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) < 0))) // Control
            {
                ExtDialog.OnClickBtnLines();
            }
        }  
        // Trade:
        else if ((MainKey_TradeHotKey != 0) && (lparam == MainKey_TradeHotKey))
        {
            if (((!ShiftRequired_TradeHotKey) || (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) < 0)) // Shift
            &&  ((!CtrlRequired_TradeHotKey)  || (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) < 0))) // Control
            {
                Trade(); 
            }
        }
    }

    // Call Panel's event handler only if it is not a CHARTEVENT_CHART_CHANGE - workaround for minimization bug on chart switch.
    if (id != CHARTEVENT_CHART_CHANGE)
    {
        ExtDialog.OnEvent(id, lparam, dparam, sparam);
        if (id >= CHARTEVENT_CUSTOM) ChartRedraw();
    }

    // Recalculate on chart changes, clicks, and certain object dragging.
    if ((id == CHARTEVENT_CLICK) || (id == CHARTEVENT_CHART_CHANGE) ||
            ((id == CHARTEVENT_OBJECT_DRAG) && ((sparam == ObjectPrefix + "EntryLine") || (sparam == ObjectPrefix + "StopLossLine") || (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1) || (sparam == ObjectPrefix + "StopPriceLine"))))
    {
        if (id == CHARTEVENT_OBJECT_DRAG) 
        {
            // Moving lines when fixed SL/TP distance is enabled. Should set a new fixed SL/TP distance.
            if ((SLDistanceInPoints) || (TPDistanceInPoints) || (ShowATROptions))
            {
                if (sparam == ObjectPrefix + "StopLossLine") ExtDialog.UpdateFixedSL();
                else if (sparam == ObjectPrefix + "TakeProfitLine") ExtDialog.UpdateFixedTP();
                else if ((sets.TakeProfitsNumber > 1) && (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1))
                {
                    int len = StringLen(ObjectPrefix + "TakeProfitLine");
                    int i = (int)StringToInteger(StringSubstr(sparam, len));
                    ExtDialog.UpdateAdditionalFixedTP(i);
                }
            }
            // Update required for additional TP fields on the Trading panel.
            if ((!TPDistanceInPoints) && (sets.TakeProfitsNumber > 1) && (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1))
            {
                int len = StringLen(ObjectPrefix + "TakeProfitLine");
                int i = (int)StringToInteger(StringSubstr(sparam, len));
                AdditionalTPLineMoved = true; // Will refresh the .Text of the Trading panel's respective TP Edit in DisplayValues().
            }
        }

        if (sparam == ObjectPrefix + "StopLossLine") StopLossLineIsBeingMoved = false; // In any case ending moving state for the stop-loss line.
        if (StringFind(sparam, ObjectPrefix + "TakeProfitLine") != -1) TakeProfitLineIsBeingMoved = false; // In any case ending moving state for the take-profit line.

        if (id != CHARTEVENT_CHART_CHANGE) ExtDialog.RefreshValues();

        static bool prev_chart_on_top = false;
        // If this is an active chart, make sure the panel is visible (not behind the chart's borders). For inactive chart, this will work poorly, because inactive charts get minimized by MetaTrader.
        if (ChartGetInteger(ChartID(), CHART_BRING_TO_TOP))
        {
            if (ExtDialog.Top() < 0) ExtDialog.Move(ExtDialog.Left(), 0);
            int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
            if (ExtDialog.Top() > chart_height) ExtDialog.Move(ExtDialog.Left(), chart_height - ExtDialog.Height());
            int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            if (ExtDialog.Left() > chart_width) ExtDialog.Move(chart_width - ExtDialog.Width(), ExtDialog.Top());
            // If chart was brought on top, refresh values to move labels.
            if ((prev_chart_on_top == false) && (ShowLineLabels)) ExtDialog.RefreshValues();
        }
        // Remember if the chart is on top or is minimized.
        prev_chart_on_top = ChartGetInteger(ChartID(), CHART_BRING_TO_TOP);
        ChartRedraw();
    }
}

//+------------------------------------------------------------------+
//| Trade event handler                                              |
//+------------------------------------------------------------------+
void OnTrade()
{
    ExtDialog.RefreshValues();
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Timer event handler                                              |
//+------------------------------------------------------------------+
void OnTimer()
{
    ExtDialog.CheckAndRestoreLines(); // Check if any lines should be restored.
    if (GetTickCount() - LastRecalculationTime < 1000) return; // Do not recalculate on timer if less than 1 second passed.
    ExtDialog.RefreshValues();
    ChartRedraw();
}
//+------------------------------------------------------------------+