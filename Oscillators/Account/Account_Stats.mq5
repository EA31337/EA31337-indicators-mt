//+------------------------------------------------------------------+
//|                                                          EA31337 |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements Account Stats indicator.
 */

// Defines.
#define INDI_FULL_NAME "Account Stats"
#define INDI_SHORT_NAME "Account_Stats"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 5
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE
#property indicator_color1 Green
#property indicator_color2 GreenYellow
#property indicator_color3 Yellow
#property indicator_color4 YellowGreen
#property indicator_color5 Red
#property indicator_width1 2
#property indicator_width2 1
#property indicator_label1 "Balance"
#property indicator_label2 "Equity"
#property indicator_label3 "Margin Available"
#property indicator_label4 "Margin Free"
#property indicator_label5 "Margin Used"
#property version "1.000"
#endif

// Includes.
//#include <EA31337-classes/Indicators/Indi_Account.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Account.mqh>
//#include <EA31337-classes/Account/AccountForex.h> // @todo

// Input parameters.
input int InpShift = 0;                                     // Shift

// Global indicator buffers.
double ExtEAAccountBalance[];
double ExtEAAccountEquity[];
double ExtEAAccountMarginAvail[];
double ExtEAAccountMarginFree[];
double ExtEAAccountMarginUsed[];

// Global variables.
Account *account;
//AccountForex *account; // @todo

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtEAAccountBalance, INDICATOR_DATA);
  SetIndexBuffer(1, ExtEAAccountEquity, INDICATOR_DATA);
  SetIndexBuffer(2, ExtEAAccountMarginAvail, INDICATOR_DATA);
  SetIndexBuffer(3, ExtEAAccountMarginFree, INDICATOR_DATA);
  SetIndexBuffer(4, ExtEAAccountMarginUsed, INDICATOR_DATA);
  // Initialize indicator for the current account.
  account = new Account();
  // account = new AccountForex(); // @todo
  string short_name =
      StringFormat("%s(%d)", INDI_SHORT_NAME, ::InpShift);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, "Balance");
  // PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
  // PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, DBL_MAX);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, ::InpShift);
  PlotIndexSetInteger(1, PLOT_SHIFT, ::InpShift);
  PlotIndexSetInteger(2, PLOT_SHIFT, ::InpShift);
  PlotIndexSetInteger(3, PLOT_SHIFT, ::InpShift);
  PlotIndexSetInteger(4, PLOT_SHIFT, ::InpShift);
  // Drawing settings (MQL4).
  SetIndexStyle(0, DRAW_LINE);
  SetIndexStyle(1, DRAW_LINE);
  SetIndexStyle(2, DRAW_LINE);
  SetIndexStyle(3, DRAW_LINE);
  SetIndexStyle(4, DRAW_LINE);
}

/**
 * Calculate event handler function.
 */
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  int i, start;
  if (rates_total <= 0) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0
              ? 0 : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    /* @todo
    AccountForexEntry _entry = account.GetEntry();
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    ExtEAAccountBalance[i] = _entry.balance;
    ExtEAAccountEquity[i] = _entry.equity;
    ExtEAAccountMarginAvail[i] = _entry.margin_avail;
    ExtEAAccountMarginFree[i] = _entry.margin_free;
    ExtEAAccountMarginUsed[i] = _entry.margin_used;
    */
    AccountEntry _entry = account.GetEntry();
    ExtEAAccountBalance[i] = _entry.balance;
    ExtEAAccountEquity[i] = _entry.equity;
    ExtEAAccountMarginAvail[i] = _entry.margin_avail;
    ExtEAAccountMarginFree[i] = _entry.margin_free;
    ExtEAAccountMarginUsed[i] = _entry.margin_used;
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete account; }