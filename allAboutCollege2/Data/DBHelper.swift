//
//  DBHelper.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/27/23.
//

import Foundation
import SQLite3


class DBHelper{
    static func getDatabasePointer(databaseName:String) -> OpaquePointer?{
        
        var databasePointer : OpaquePointer?
        let documentDatabasePath = FileManager.default.urls(for:.documentDirectory , in:
                .userDomainMask)[0].appendingPathComponent(databaseName).path
        
        if FileManager.default.fileExists(atPath: documentDatabasePath){
            print("Database Exists(already)")
        }
        
        else{
            guard let bundleDatabasePath = Bundle.main.resourceURL?.appendingPathComponent(databaseName).path else{
                print("Unwrapping Error: Bundle Database Path doesn't exist")
                return nil
            }
            do{
                try FileManager.default.copyItem(atPath: bundleDatabasePath, toPath: documentDatabasePath)
                print("Database created (copied)")
            } catch{
                print("Error:\(error.localizedDescription)")
                return nil
            }
        }
        if sqlite3_open(documentDatabasePath,&databasePointer)==SQLITE_OK{
            print("Successfully open database")
            print("Database path:\(documentDatabasePath)")
        }
        else{
            print("Could not open database")
        }
        return databasePointer
    }
    
    
    func getSomeGrade(courAbb:String, courNum:Int)-> [Grade]{
        var mainList = [Grade]()
        var finalList = [Grade]()
        let tableName = term.lowercased()+year
        let query="SELECT * FROM \(tableName) WHERE CRSSUBJCD = ? AND CRSNBR = ? "
        print(tableName)
        var statement : OpaquePointer?
        if sqlite3_prepare_v2(databasePointer, query, -1, &statement, nil) == SQLITE_OK{
            
            sqlite3_bind_text(statement, 1, (courAbb.uppercased() as NSString).utf8String,-1 , nil)
            sqlite3_bind_int(statement, 2, Int32(courNum))
            while sqlite3_step(statement) == SQLITE_ROW{
                let courAbb = String(describing:String(cString:sqlite3_column_text(statement, 0)))
                let courNum = Int(sqlite3_column_int(statement, 1))
                let courTitle = String(describing:String(cString:sqlite3_column_text(statement, 2)))
                let aplusNum = Int(sqlite3_column_int(statement, 3))
                let aNum = Int(sqlite3_column_int(statement, 4))
                
                let aminusNum = Int(sqlite3_column_int(statement, 5))
                let bplusNum = Int(sqlite3_column_int(statement, 6))
                let bNum = Int(sqlite3_column_int(statement, 7))
           
                let bminusNum = Int(sqlite3_column_int(statement, 8))
                let cplusNum = Int(sqlite3_column_int(statement, 9))
                let cNum = Int(sqlite3_column_int(statement, 10))
        
                let cminusNum = Int(sqlite3_column_int(statement, 11))
                let dplusNum = Int(sqlite3_column_int(statement, 12))
                let dNum = Int(sqlite3_column_int(statement, 13))
              
                let dminusNum = Int(sqlite3_column_int(statement, 14))
                let fNum = Int(sqlite3_column_int(statement, 15))
                
                let withdraw = Int(sqlite3_column_int(statement, 16))
                let instructor = String(describing:String(cString:sqlite3_column_text(statement, 17)))
                let regs = Int(sqlite3_column_int(statement, 18))
                let grade = Grade()
                grade.courAbb = courAbb
                grade.courNum = courNum
                grade.courTitle = courTitle
                
                grade.aNum = aNum
                grade.aplusNum  = aplusNum
                grade.aminusNum  = aminusNum
                
                grade.bNum = bNum
                grade.bplusNum  = bplusNum
                grade.bminusNum  = bminusNum
                
                grade.cNum = cNum
                grade.cplusNum  = cplusNum
                grade.cminusNum  = cminusNum
                
                grade.dNum = dNum
                grade.dplusNum  = dplusNum
                grade.dminusNum  = dminusNum
                
                grade.fNum = fNum
                
                grade.withdraw = withdraw
                grade.instructor = instructor
                grade.regs = regs
                
                mainList.append(grade)
            }
        }
        
        for grade in mainList{
            var isDuplicate:Bool = false
            for i in 0..<finalList.count{
                if grade.instructor == finalList[i].instructor {
                    isDuplicate = true
                    
                    finalList[i].aNum += grade.aNum
                    finalList[i].aplusNum += grade.aplusNum
                    finalList[i].aminusNum += grade.aminusNum
                    
                    finalList[i].bNum += grade.bNum
                    finalList[i].bplusNum += grade.bplusNum
                    finalList[i].bminusNum += grade.bminusNum
                    
                    finalList[i].cNum += grade.cNum
                    finalList[i].cplusNum += grade.cplusNum
                    finalList[i].cminusNum += grade.cminusNum
                    
                    finalList[i].dNum += grade.dNum
                    finalList[i].dplusNum += grade.dplusNum
                    finalList[i].dminusNum += grade.dminusNum
                    
                    finalList[i].fNum += grade.fNum
                    finalList[i].withdraw += grade.withdraw
                    finalList[i].regs += grade.regs
                    break
                }
            }
            if isDuplicate == true {
                print("finalList1")
                continue
            }
            else{
                print("finalList2")
                finalList.append(grade)
            }
        }
        
        return finalList
    }
    
   
}
    

