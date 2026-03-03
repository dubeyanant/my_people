package com.infiniteants.mypeople

import io.flutter.embedding.android.FlutterFragmentActivity
import androidx.activity.enableEdgeToEdge

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
    }
}
