import Foundation
import UIKit

public class TxTableViewController : UITableViewController{
    
    var txArray = [String]()
    
    public override func viewDidLoad() {
        //some shit here
        txArray = ["blah blah1", "blah blah2", "blah blah3"]
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TxCell")
        cell?.textLabel?.text = txArray[indexPath.row]
        return cell!
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
