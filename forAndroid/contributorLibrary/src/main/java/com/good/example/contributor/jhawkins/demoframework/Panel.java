/* Copyright (c) 2015 Good Technology Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.good.example.contributor.jhawkins.demoframework;

import java.util.ArrayList;

public abstract class Panel {
    private ArrayList<ArrayList<PanelItem>> demoPanelItemDivisions;

    protected UserInterface userInterface = null;

    public Panel setUserInterface(UserInterface userInterface) {
        this.userInterface = userInterface;
        return this;
    }
    public UserInterface userInterface() {
        return this.userInterface;
    }

    public void demoPanelLoad(Boolean andRefresh)
    {
        if (andRefresh && this.userInterface != null) {
            this.userInterface.refresh();
        }
    }

    // Accessors for panel items.
    //
    // getters.
    public int demoPanelDivisionCount() {
        if (demoPanelItemDivisions == null) return 0;
        return demoPanelItemDivisions.size();
    }
    public int demoPanelItemCount(int division) {
        if (demoPanelItemDivisions == null) return 0;
        if (demoPanelItemDivisions.size() <= division) return 0;
        return demoPanelItemDivisions.get(division).size();
    }
    public PanelItem panelItem(int division, int item) {
        if (demoPanelItemDivisions == null) return null;
        if (demoPanelItemDivisions.size() <= division) return null;
        if (demoPanelItemDivisions.get(division).size() <= item) return null;
        return demoPanelItemDivisions.get(division).get(item);
    }
    //
    // setters.
    public void deleteAllDivisions () {
        demoPanelItemDivisions = null;
    }
    public int[] appendToDivision(int divisionNumber, PanelItem panelItem) {
        if (demoPanelItemDivisions == null) {
            demoPanelItemDivisions = new ArrayList<ArrayList<PanelItem>>(0);
        }
        while (demoPanelItemDivisions.size() <= divisionNumber) {
            demoPanelItemDivisions.add(new ArrayList<PanelItem>(0));
        }
        ArrayList<PanelItem> division = demoPanelItemDivisions.get(divisionNumber);
        int[] location = new int[3];
        location[0] = divisionNumber;
        location[1] = division.size();
        if (panelItem != null) {
            panelItem.location = location;
            panelItem.panel = this;
            division.add(panelItem);
        }
        return location;
    }
//    public int addDivision(PanelItem panelItem) {
//        PanelItem[] division = new PanelItem[1];
//        division[0] = panelItem;
//        return addDivision(division);
//    }
    public int addDivision(PanelItem ... panelItems) {
        int division = demoPanelDivisionCount();
        appendToDivision(division, null);
        for (PanelItem panelItem : panelItems) {
            appendToDivision(division, panelItem);
        }
        return division;
    }
    public PanelItem removeItemAt(int divisionNumber, int itemNumber) {
        ArrayList<PanelItem> division = demoPanelItemDivisions.get(divisionNumber);
        return division.remove(itemNumber);
    }

}
