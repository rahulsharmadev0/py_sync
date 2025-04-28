import 'package:flutter/material.dart';
import 'package:flutter_suite/flutter_suite.dart';
import 'package:intl/intl.dart';
import 'package:py_sync/logic/models/device.dart';

class TableBody extends StatelessWidget {
  final List<Widget> rows;
  const TableBody({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const CenterText(text: 'No devices found');
    }
    return Expanded(
      child: ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => rows[index],
      ),
    );
  }
}

class FormetDateTime extends StatelessWidget {
  final DateTime? dateTime;
  const FormetDateTime(this.dateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      dateTime == null ? 'N/A' : DateFormat('dd-MMM-yyyy, hh:mm a').format(dateTime!),
      style: context.$TxT.t2?.$color(Colors.black54),
    );
  }
}

class CenterText extends StatelessWidget {
  final String text;
  const CenterText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: context.$TxT.t2?.$color(Colors.black54)));
  }
}

class HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const HeaderCell({super.key, required this.text, this.flex = 1});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: context.$TxT.b2?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}

class TableHeader extends StatelessWidget {
  final List<({String text, int flex})> headers;
  const TableHeader({super.key, required this.headers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          for (var header in headers) HeaderCell(text: header.text, flex: header.flex),
        ],
      ),
    );
  }
}

class DeviceIdCell extends StatelessWidget {
  final Device device;
  const DeviceIdCell(this.device, {super.key});

  @override
  Widget build(BuildContext context) {
    var children = [
      Text(
        device.deviceId,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      SizedBox(
        height: 24,
        child: FittedBox(
          child: Tooltip(message: device.type, child: Chip(label: Text(device.name))),
        ),
      ),
    ];
    return Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: children);
  }
}
