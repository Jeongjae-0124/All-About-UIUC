//
//  gradeDetailViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/28/23.
//

import UIKit
import DGCharts
import SafariServices

class gradeDetailViewController: UIViewController {
    var gradeselected:Grade?
    var link:String?
    @IBOutlet weak var withdraw: UILabel!
    @IBOutlet weak var totalReg: UILabel!
    @IBOutlet weak var barGraphView: BarChartView!
    @IBOutlet weak var courseAbb: UILabel!
    @IBOutlet weak var courseTerm: UILabel!
    @IBOutlet weak var courseInstr: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
  
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var infoView2: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.layer.borderWidth = 2
        infoView.layer.borderColor = UIColor.black.cgColor
        infoView2.layer.borderWidth = 2
        infoView2.layer.borderColor = UIColor.black.cgColor
        self.courseTitle.numberOfLines=0
        courseTitle.adjustsFontSizeToFitWidth=true
        courseTerm.text = "Term: "+term + year
        courseInstr.text = gradeselected!.instructor
        courseTitle.text = gradeselected!.courTitle
        courseAbb.text = (gradeselected!.courAbb?.uppercased())! + String(gradeselected!.courNum)
        withdraw.text = "Withdraw: " + String(gradeselected!.withdraw)
        totalReg.text = "Total Registered: " + String(gradeselected!.regs)
        createChart()
        
    }

    
    private func createChart(){
        var dataPoints: [String]=["A+","A","A-","B+","B","B-","C+","C","C-","D+","D","D-","F"]
        var dataEntries:[BarChartDataEntry]=[]
        
        let Apluspercent = (Float(gradeselected?.aplusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        print("aplus:\(gradeselected?.aplusNum)")
        let Apercent = (Float(gradeselected?.aNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Aminuspercent = (Float(gradeselected?.aminusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        
        let Bpluspercent = (Float(gradeselected?.bplusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Bpercent = (Float(gradeselected?.bNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Bminuspercent = (Float(gradeselected?.bminusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        
        let Cpluspercent = (Float(gradeselected?.cplusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Cpercent = (Float(gradeselected?.cNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Cminuspercent = (Float(gradeselected?.cminusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        
        let Dpluspercent = (Float(gradeselected?.dplusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Dpercent = (Float(gradeselected?.dNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        let Dminuspercent = (Float(gradeselected?.dminusNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        
        let Fpercent = (Float(gradeselected?.fNum ?? 0) / Float(gradeselected?.regs ?? 0))*100
        
        var dataArray:[Float] = [Apluspercent,Apercent,Aminuspercent,Bpluspercent,Bpercent,Bminuspercent,Cpluspercent,Cpercent,Cminuspercent,Dpluspercent,Dpercent,Dminuspercent,Fpercent]
        
        for i in 0...12{
            let dataEntry = BarChartDataEntry(x: Double(i),y:Double(dataArray[i]))
            dataEntries.append(dataEntry)
        }
       
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "graph data")
        let chartData = BarChartData(dataSet: chartDataSet)
        
       
        barGraphView.xAxis.drawAxisLineEnabled=false
        barGraphView.legend.enabled = false
        barGraphView.chartDescription.enabled = false
        barGraphView.xAxis.drawGridLinesEnabled=false
        barGraphView.xAxis.labelPosition = .bottom
        barGraphView.xAxis.labelFont = UIFont.systemFont(ofSize: 15)
        barGraphView.xAxis.setLabelCount(dataPoints.count, force: false)
        barGraphView.xAxis.valueFormatter=IndexAxisValueFormatter(values: dataPoints)
        barGraphView.leftAxis.drawGridLinesEnabled=false
        barGraphView.leftAxis.drawAxisLineEnabled=false
        barGraphView.leftAxis.drawLabelsEnabled=false

//        barGraphView.xAxis.avoidFirstLastClippingEnabled = false
        barGraphView.leftAxis.spaceBottom = 0.0
        barGraphView.rightAxis.drawAxisLineEnabled=false
        barGraphView.rightAxis.drawLabelsEnabled = false
        barGraphView.rightAxis.drawGridLinesEnabled=false
//        barGraphView.minOffset = 0

        chartDataSet.valueFont=UIFont.systemFont(ofSize: 10)
        barGraphView.xAxis.yOffset = 0
        
        barGraphView.data = chartData
        let valFormatter = NumberFormatter()
        valFormatter.numberStyle = .percent
        valFormatter.maximumFractionDigits=1
        valFormatter.percentSymbol="%"
        valFormatter.multiplier=1.0
        let valFormat = DefaultValueFormatter(formatter: valFormatter)
        chartDataSet.valueFormatter=valFormat
    }
}
