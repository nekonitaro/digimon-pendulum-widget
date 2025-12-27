package com.yourcompany.digimon_pendulum

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "digimon.deeplink"
    private val EVENT_CHANNEL = "digimon.deeplink/events"
    private var linkStreamHandler: LinkStreamHandler? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                val link = intent?.data?.toString()
                result.success(link)
            } else {
                result.notImplemented()
            }
        }
        
        linkStreamHandler = LinkStreamHandler()
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(linkStreamHandler)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleDeepLink(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleDeepLink(intent)
    }
    
    private fun handleDeepLink(intent: Intent?) {
        val data = intent?.data
        if (data != null) {
            android.util.Log.d("MainActivity", "ディープリンク: $data")
            linkStreamHandler?.send(data.toString())
        }
    }
    
    class LinkStreamHandler : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null
        
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
        }
        
        override fun onCancel(arguments: Any?) {
            eventSink = null
        }
        
        fun send(link: String) {
            eventSink?.success(link)
        }
    }
}