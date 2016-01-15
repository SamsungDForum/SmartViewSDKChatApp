/**
 * Created with JetBrains WebStorm.
 * User: ser.voloshyn
 * Date: 16/07/13
 * Time: 16:37
 * To change this template use File | Settings | File Templates.
 */
var Device = {};

/*
    constructor for device object
 */
Device.Model = function (deviceId, deviceName){
    var id = deviceId,
        name = deviceName;
    this.getId = function (){
        return id;
    };
    this.getName = function (){
        return name;
    };
    this.equals = function(obj){
        if (obj instanceof Device.Model){
            if (this.getId() == obj.getId()){
                return true;
            }
        }
        return false;
    }
};