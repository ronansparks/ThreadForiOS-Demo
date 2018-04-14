//
//  NSOperationTableVC.swift
//  ThreadForiOS
//
//  Created by Ronan on 4/14/18.
//  Copyright © 2018 RonanStudio. All rights reserved.
//

import UIKit

class OperationTableVC: UITableViewController {

    var indicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicatorView.color = .green
        indicatorView.center = view.center
        view.addSubview(indicatorView)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let combo = (section, row)
        switch combo {
        case (0, 0):
            testBlockOperation()
        case (0, 1):
            testCustomOperation()
        case (1, 0):
            testBlockOperationAsync()
        case (1, 1):
            testOperationAddToQueue()
        case (1, 2):
            testQueueBlock()
        case (2, 0):
            testCommunication()
        case (2, 1):
            testMaxConcurrent()
        case (2, 2):
            testDependency()
        default:
            print("")
        }
    }
    
    func testBlockOperation() {
        let blockOperation = BlockOperation {
            print("This is \(#function)")
        }
        blockOperation.start()
    }
    
    func testCustomOperation() {
        let rwOperation = RWOperation()
        rwOperation.start()
    }
    
    //创建操作，不用加入队列，实现异步执行
    func testBlockOperationAsync() {
        let blockOperation = BlockOperation {
            print("This is \(#function)")
        }
        for i in 0...3 {
            blockOperation.addExecutionBlock {
                print("then execute \(#function) \(i)")
            }
        }
        blockOperation.start()
    }
    
    //创建几个操作，添加到队列，实现异步执行
    func testOperationAddToQueue() {
        let queue = OperationQueue()
        
        for i in 0...3 {
            let blockOperation = BlockOperation {
                print("Task \(i)")
            }
            queue.addOperation(blockOperation)
        }
    }
    
    //不需要单独创建操作，实现异步执行
    func testQueueBlock() {
        //默认是并发
        let queue = OperationQueue()
        for i in 0...3 {
            queue.addOperation {
                print("Task \(i) in Queue")
            }
        }
    }
    
    //线程间通信
    func testCommunication() {
        indicatorView.startAnimating()
        let queue = OperationQueue()
        queue.addOperation {
            //睡眠3s 假装执行耗时任务，如下载
            Thread.sleep(forTimeInterval: 3)
            
            //回到主线程，操作UI
            OperationQueue.main.addOperation({
                self.indicatorView.stopAnimating()
            })
        }
    }
    
    //最大并发数
    func testMaxConcurrent() {
        let queue = OperationQueue()
        
        //最大并发数为1，串行
//        queue.maxConcurrentOperationCount = 1
        
        //最大并发数为2，并发
        queue.maxConcurrentOperationCount = 2
        
        for i in 0...3 {
            queue.addOperation {
                print("Task \(i)")
            }
        }
    }
    
    func testDependency() {
        let queue = OperationQueue()
        let blockOperation1 = BlockOperation {
            for i in 0...3 {
                print("Task 1 \(i)")
            }
        }
        
        let blockOperation2 = BlockOperation {
            for i in 0...3 {
                print("Task 2 \(i)")
            }
        }
        
        //注释掉，任务1和2没有先后顺序
        blockOperation2.addDependency(blockOperation1)
        
        queue.addOperation(blockOperation1)
        queue.addOperation(blockOperation2)
    }
}
