import Foundation
import UIKit

public class TxTableViewController : UITableViewController{
    
    var txArray = [String]()
    
    public override func viewDidLoad() {
        //some shit here
        txArray = ["blah blah1", "blah blah2", "blah blah3"]
    }
        
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TxCell")
        cell?.textLabel?.text = txArray[indexPath.row]
        return cell!
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
