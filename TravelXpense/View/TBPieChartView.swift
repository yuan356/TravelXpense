//
//  TBChart.swift
//  ChartDemo
//
//  Created by 阿遠 on 2020/10/27.
//

import UIKit
import Charts

class TBPieChartView: PieChartView {
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        return formatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.holeColor = UIColor.clear
        self.legend.textColor = UIColor.white
        self.animate(yAxisDuration: 0.6)
        self.extraTopOffset = 8
        self.extraBottomOffset = 8
        self.legend.enabled = false
        self.usePercentValuesEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeCenterText(text: String) {
        let myAttribute = [ NSAttributedString.Key.font: MainFont.medium.with(fontSize: .medium), NSAttributedString.Key.foregroundColor: UIColor.white ]
        let myAttrString = NSAttributedString(string: text, attributes: myAttribute)
        self.centerAttributedText = myAttrString
    }
    
    var dataSet = PieChartDataSet()
    
    func setData(datalist: [CategoryAmount]) {
        var entryColors = [NSUIColor]()
        let dataEntries = datalist.reduce(into: [PieChartDataEntry](), { (result, data) in
            if data.amount != 0 {
                var amount = data.amount
                amount.turnToPositive()
                result.append(PieChartDataEntry(value: amount))
                entryColors.append(UIColor(hex: data.category.colorHex))
            }
        })
        
        dataSet = PieChartDataSet(entries: dataEntries)
        dataSet.valueLinePart1OffsetPercentage = 0.7
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueLineColor = UIColor.white
        dataSet.colors = entryColors
        dataSet.selectionShift = 0
        
        let data = PieChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter:formatter))

        self.data = data
    }
}
