import 'package:flutter/material.dart';

class Day{
  Day(this.day, [this.begin1 = const TimeOfDay(hour: 0, minute: 0), this.end1 = const TimeOfDay(hour: 0, minute: 0) , this.begin2 = const TimeOfDay(hour: 0, minute: 0), this.end2 = const TimeOfDay(hour: 0, minute: 0)]){
    open = !(this.begin1.hour == 0 && this.begin1.minute == 0 && this.end1.hour == 0 && this.end1.minute == 0);
    split = !(this.begin2.hour == 0 && this.begin2.minute == 0 && this.end2.hour == 0 && this.end2.minute == 0);
  }

  final String day;
  bool open;
  bool split;
  TimeOfDay begin1;
  TimeOfDay end1;
  TimeOfDay begin2;
  TimeOfDay end2;

  void setOpen(bool open){
    this.open = open;
    if(!open){
      split = false;
    }
  }

  Map<String, dynamic> toJson() =>
    {
      'day' : this.day,
      'open' : this.open,
      'split' : this.split,
      'begin1' : this.begin1.toString(),
      'end1' : this.end1.toString(),
      'begin2' : this.begin2.toString(),
      'end2' : this.end2.toString(),
    };

  String toString(){
    if(!open){
      return "fermé";
    }

    String begin1Min = begin1.minute == 0 ? "00" : begin1.minute.toString();
    String end1Min = end1.minute == 0 ? "00" : end1.minute.toString();
    String str =  begin1.hour.toString()+ "h" + begin1Min + " - "+ end1.hour.toString() + "h" + end1Min;
    if(split){
      String begin2Min = begin2.minute == 0 ? "00" : begin2.minute.toString();
      String end2Min = end2.minute == 0 ? "00" : end2.minute.toString();
      str += " et " + begin2.hour.toString()+ "h" + begin2Min + " - "+ end2.hour.toString() + "h" + end2Min;
    }
    return str;
  }
}